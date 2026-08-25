// =============================================================================
// PROJECT AGNES — 02_demo_queries.cypher
// SME Cypher Templates  (box `3n` on the instructor's Agentic GraphRAG slide)
//
// These are expert-authored, PARAMETERISED queries the agent calls as tools.
// The agent supplies the parameter; it does not get to invent the query shape.
// That is what makes this retriever both accurate and containable.
//
// THE ONE IDEA: every Evidence node carries `public_from`. Every template
// filters on it. Move the date and the assessment recomputes. The graph is
// never rebuilt — the later evidence is physically present the whole time,
// it is simply not eligible.
//
// SET THE PARAMETER FIRST (Neo4j Browser):
//     :param cutoff => date('2021-02-10')
// If :param is unsupported in your editor, use the LITERAL VARIANTS at the
// bottom of this file — copy-paste ready, no parameters needed.
//
// ASSUMPTION STATES — four, and the distinction matters:
//   SUPPORTED                 evidence for, none against
//   CHALLENGED                evidence against exists, but not decisive
//   CONTRADICTED              evidence against outweighs
//   INSUFFICIENTLY_EVIDENCED  nothing eligible either way — we do not know
// A system that never says "we do not know" is asserting, not assessing.
// =============================================================================


// =============================================================================
// T1 · ASSESS  — "What had to be true, and what does the evidence say?"
// SAY: these are the propositions the bet rests on, judged only on what was
//      public on this date.
// EXPECT at 2021-02-10: liquidity SUPPORTED, unit economics CONTRADICTED,
//      holding CHALLENGED, demand SUPPORTED, forecast + throughput UNKNOWN.
// =============================================================================
MATCH (a:Assumption)
OPTIONAL MATCH (es:Evidence)-[sup:SUPPORTS]->(a)      WHERE es.public_from <= $cutoff
WITH a, sum(coalesce(sup.strength, 0)) AS support
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a)   WHERE ec.public_from <= $cutoff
WITH a, support, sum(coalesce(con.strength, 0)) AS contra
RETURN a.statement AS assumption,
       round(support, 2) AS evidence_for,
       round(contra, 2)  AS evidence_against,
       CASE
         WHEN support + contra = 0            THEN 'INSUFFICIENTLY_EVIDENCED'
         WHEN contra = 0                      THEN 'SUPPORTED'
         WHEN support = 0 AND contra >= 0.5   THEN 'CONTRADICTED'
         WHEN support = 0                     THEN 'CHALLENGED'
         WHEN support >= contra               THEN 'CHALLENGED'
         ELSE 'CONTRADICTED'
       END AS state
ORDER BY evidence_against DESC, evidence_for DESC;


// =============================================================================
// T2 · MONITOR  — the hero. Both checkpoints, side by side.
// SAY: I changed one date. Nothing else. Not the graph, not the ontology,
//      not the prompt. Watch which rows move — and which do not.
// EXPECT: throughput UNKNOWN -> CONTRADICTED. holding CHALLENGED ->
//      CONTRADICTED. liquidity SUPPORTED -> CHALLENGED.
//      demand SUPPORTED -> SUPPORTED (unchanged — the demand side was fine).
//      forecast UNKNOWN -> UNKNOWN (never any public evidence either way).
// =============================================================================
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (a:Assumption)
OPTIONAL MATCH (es:Evidence)-[sup:SUPPORTS]->(a)      WHERE es.public_from <= cutoff
WITH cutoff, a, sum(coalesce(sup.strength, 0)) AS support
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a)   WHERE ec.public_from <= cutoff
WITH cutoff, a, support, sum(coalesce(con.strength, 0)) AS contra
WITH cutoff, a,
     CASE
       WHEN support + contra = 0            THEN 'INSUFFICIENTLY_EVIDENCED'
       WHEN contra = 0                      THEN 'SUPPORTED'
       WHEN support = 0 AND contra >= 0.5   THEN 'CONTRADICTED'
       WHEN support = 0                     THEN 'CHALLENGED'
       WHEN support >= contra               THEN 'CHALLENGED'
       ELSE 'CONTRADICTED'
     END AS state
WITH a.statement AS assumption,
     max(CASE WHEN cutoff = date('2021-02-10') THEN state END) AS at_10_feb,
     max(CASE WHEN cutoff = date('2021-08-05') THEN state END) AS at_05_aug
RETURN assumption, at_10_feb, at_05_aug,
       CASE WHEN at_10_feb = at_05_aug THEN '' ELSE '<<< CHANGED' END AS moved
ORDER BY moved DESC, assumption;


// =============================================================================
// T3 · SIMULATE + DECIDE  — score every form of the bet on the same evidence.
// SAY: same evidence, three structures. The structure decides how much of the
//      evidence you are exposed to.
// EXPECT at 2021-02-10: aggressive positive -> CONTINUE WITH GUARDRAILS.
// EXPECT at 2021-08-05: aggressive turns NEGATIVE -> REASSESS / PAUSE-SCALE.
//      That sign change is the decision-relevant event.
// =============================================================================
MATCH (sc:Scenario)-[req:REQUIRES]->(a:Assumption)
OPTIONAL MATCH (es:Evidence)-[sup:SUPPORTS]->(a)      WHERE es.public_from <= $cutoff
WITH sc, req, a, sum(coalesce(sup.strength, 0)) AS support
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a)   WHERE ec.public_from <= $cutoff
WITH sc, req, support, sum(coalesce(con.strength, 0)) AS contra
WITH sc, req,
     CASE
       WHEN support + contra = 0            THEN  0.0
       WHEN contra = 0                      THEN  1.0
       WHEN support = 0 AND contra >= 0.5   THEN -1.0
       WHEN support = 0                     THEN  0.3
       WHEN support >= contra               THEN  0.3
       ELSE -1.0
     END AS val
WITH sc,
     sum(req.weight * val)  AS weighted,
     sum(req.weight)        AS total_weight,
     sum(CASE WHEN val = -1.0 AND req.weight >= 0.7 THEN 1 ELSE 0 END) AS critical_broken
WITH sc, round(weighted / total_weight, 3) AS score, critical_broken
RETURN sc.name              AS scenario,
       sc.capital_intensity AS capital_intensity,
       score,
       critical_broken      AS critical_assumptions_broken,
       CASE WHEN score < 0        THEN 'REASSESS / PAUSE-SCALE'
            WHEN critical_broken > 0 THEN 'CONTINUE WITH GUARDRAILS'
            ELSE 'CONTINUE' END AS action
ORDER BY score DESC;


// =============================================================================
// T4 · CONTROL  — tripwires. Frozen BEFORE, evaluated AFTER.
// SAY: this threshold was committed on 10 February and never touched. The
//      graph does not store whether it fired — that is computed against
//      whatever evidence is eligible. Storing the answer would be hindsight.
// EXPECT at 2021-02-10: NO ELIGIBLE EVIDENCE (nothing to test against yet).
// EXPECT at 2021-08-05: FIRED. $1.169601bn against a $1bn guardrail.
// =============================================================================
MATCH (t:Tripwire)-[:WATCHES]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)
  WHERE e.metric = t.metric AND e.public_from <= $cutoff
WITH t, a, e ORDER BY e.public_from DESC
WITH t, a, head(collect(e)) AS latest
RETURN t.condition        AS tripwire,
       t.frozen_on        AS frozen_on,
       t.threshold        AS threshold,
       latest.value       AS observed,
       latest.public_from AS observed_from,
       a.statement        AS watches,
       CASE WHEN latest IS NULL              THEN 'NO ELIGIBLE EVIDENCE'
            WHEN latest.value > t.threshold  THEN 'FIRED'
            ELSE 'NOT FIRED' END AS status,
       CASE WHEN latest IS NOT NULL AND latest.value > t.threshold
            THEN t.action ELSE '' END AS triggered_action
ORDER BY status DESC;


// =============================================================================
// T5 · DEPENDENCIES  — the narration path. SWITCH THE RESULT VIEW TO "GRAPH".
// SAY: evidence -> assumption -> exposure -> scenario. One traversal, and you
//      can see exactly why the decision moved.
// Hold this in reserve for Q&A if the three minutes are tight.
// =============================================================================
MATCH p1 = (:StrategicBet)-[:HAS_SCENARIO]->(sc:Scenario {id: 'scn_aggressive'})
           -[:REQUIRES]->(a:Assumption)-[:IF_FALSE_CAUSES]->(:Exposure)
MATCH p2 = (e:Evidence)-[:CONTRADICTS]->(a)
WHERE e.public_from <= $cutoff
RETURN p1, p2;


// =============================================================================
// T6 · SHADOW-MONITOR  — the alternatives you did not choose.
// SAY: capital-light does not improve. It barely moves. Almost none of the
//      new evidence bears on it — that is the whole point of the structure.
//      The graph cannot know how an unchosen strategy WOULD have performed.
//      It updates how that alternative would CURRENTLY be expected to perform.
// EXPECT (verified):
//      aggressive     +0.217  ->  -0.283   SIGN FLIP. action changes.
//      hybrid         +0.257  ->  -0.149   also flips.
//      capital-light  +0.488  ->  +0.312   barely moves. still CONTINUE.
//      gap aggressive->capital-light: 0.271 -> 0.595. More than doubles.
//
// NOTE — capital-light ranks highest at BOTH dates. There is no ranking
// crossover, and that is deliberate: a referral model IS structurally less
// exposed, and the graph never pretended otherwise. The decision-relevant
// event is the SIGN CHANGE on aggressive, not a change in ranking. This also
// means the weights were not tuned to manufacture a crossover — say so if
// anyone asks whether the numbers were fitted.
// =============================================================================
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (sc:Scenario)-[req:REQUIRES]->(a:Assumption)
OPTIONAL MATCH (es:Evidence)-[sup:SUPPORTS]->(a)      WHERE es.public_from <= cutoff
WITH cutoff, sc, req, a, sum(coalesce(sup.strength, 0)) AS support
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a)   WHERE ec.public_from <= cutoff
WITH cutoff, sc, req, support, sum(coalesce(con.strength, 0)) AS contra
WITH cutoff, sc, req,
     CASE
       WHEN support + contra = 0            THEN  0.0
       WHEN contra = 0                      THEN  1.0
       WHEN support = 0 AND contra >= 0.5   THEN -1.0
       WHEN support = 0                     THEN  0.3
       WHEN support >= contra               THEN  0.3
       ELSE -1.0
     END AS val
WITH cutoff, sc, round(sum(req.weight * val) / sum(req.weight), 3) AS score
WITH sc.name AS scenario,
     max(CASE WHEN cutoff = date('2021-02-10') THEN score END) AS at_10_feb,
     max(CASE WHEN cutoff = date('2021-08-05') THEN score END) AS at_05_aug
RETURN scenario, at_10_feb, at_05_aug,
       round(at_05_aug - at_10_feb, 3) AS change
ORDER BY at_05_aug DESC;


// =============================================================================
// T7 · EXPOSURE AMPLIFICATION  — why the same failure costs different amounts.
// SAY: the assumption breaks identically in all three scenarios. What differs
//      is how much of it lands on your balance sheet.
// Uses the CARRIES multiplier. Good Q&A material.
// =============================================================================
MATCH (sc:Scenario)-[c:CARRIES]->(x:Exposure)<-[:IF_FALSE_CAUSES]-(a:Assumption)
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a) WHERE ec.public_from <= $cutoff
WITH sc, x, a, sum(coalesce(con.strength, 0)) AS contra, c.multiplier AS mult
WHERE contra > 0
RETURN sc.name AS scenario, x.name AS exposure, a.statement AS broken_assumption,
       mult AS multiplier, x.severity AS severity,
       round(contra * mult * x.severity, 3) AS realised_exposure
ORDER BY realised_exposure DESC;


// =============================================================================
// SUPPORTING QUERY · what was eligible on each date (for the "data" criterion)
// =============================================================================
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (e:Evidence) WHERE e.public_from <= cutoff
WITH cutoff, count(e) AS eligible, collect(e.statement) AS statements
RETURN cutoff, eligible, statements ORDER BY cutoff;


// =============================================================================
// =============================================================================
//  LITERAL VARIANTS — if :param does not work in your editor.
//  Identical queries, date hard-coded. Change the date in ONE place per query.
// =============================================================================
// =============================================================================


// --- T1 · ASSESS at 2021-02-10 (change to 2021-08-05 and re-run) -------------
MATCH (a:Assumption)
OPTIONAL MATCH (es:Evidence)-[sup:SUPPORTS]->(a)      WHERE es.public_from <= date('2021-02-10')
WITH a, sum(coalesce(sup.strength, 0)) AS support
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a)   WHERE ec.public_from <= date('2021-02-10')
WITH a, support, sum(coalesce(con.strength, 0)) AS contra
RETURN a.statement AS assumption,
       round(support, 2) AS evidence_for,
       round(contra, 2)  AS evidence_against,
       CASE
         WHEN support + contra = 0            THEN 'INSUFFICIENTLY_EVIDENCED'
         WHEN contra = 0                      THEN 'SUPPORTED'
         WHEN support = 0 AND contra >= 0.5   THEN 'CONTRADICTED'
         WHEN support = 0                     THEN 'CHALLENGED'
         WHEN support >= contra               THEN 'CHALLENGED'
         ELSE 'CONTRADICTED'
       END AS state
ORDER BY evidence_against DESC, evidence_for DESC;


// --- T3 · SIMULATE at 2021-02-10 (change to 2021-08-05 and re-run) -----------
MATCH (sc:Scenario)-[req:REQUIRES]->(a:Assumption)
OPTIONAL MATCH (es:Evidence)-[sup:SUPPORTS]->(a)      WHERE es.public_from <= date('2021-02-10')
WITH sc, req, a, sum(coalesce(sup.strength, 0)) AS support
OPTIONAL MATCH (ec:Evidence)-[con:CONTRADICTS]->(a)   WHERE ec.public_from <= date('2021-02-10')
WITH sc, req, support, sum(coalesce(con.strength, 0)) AS contra
WITH sc, req,
     CASE
       WHEN support + contra = 0            THEN  0.0
       WHEN contra = 0                      THEN  1.0
       WHEN support = 0 AND contra >= 0.5   THEN -1.0
       WHEN support = 0                     THEN  0.3
       WHEN support >= contra               THEN  0.3
       ELSE -1.0
     END AS val
WITH sc, sum(req.weight * val) AS weighted, sum(req.weight) AS total_weight,
     sum(CASE WHEN val = -1.0 AND req.weight >= 0.7 THEN 1 ELSE 0 END) AS critical_broken
WITH sc, round(weighted / total_weight, 3) AS score, critical_broken
RETURN sc.name AS scenario, sc.capital_intensity AS capital_intensity, score,
       critical_broken AS critical_assumptions_broken,
       CASE WHEN score < 0           THEN 'REASSESS / PAUSE-SCALE'
            WHEN critical_broken > 0 THEN 'CONTINUE WITH GUARDRAILS'
            ELSE 'CONTINUE' END AS action
ORDER BY score DESC;


// --- T4 · CONTROL at 2021-02-10 (change to 2021-08-05 and re-run) ------------
MATCH (t:Tripwire)-[:WATCHES]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)
  WHERE e.metric = t.metric AND e.public_from <= date('2021-02-10')
WITH t, a, e ORDER BY e.public_from DESC
WITH t, a, head(collect(e)) AS latest
RETURN t.condition AS tripwire, t.frozen_on AS frozen_on, t.threshold AS threshold,
       latest.value AS observed, latest.public_from AS observed_from,
       a.statement AS watches,
       CASE WHEN latest IS NULL             THEN 'NO ELIGIBLE EVIDENCE'
            WHEN latest.value > t.threshold THEN 'FIRED'
            ELSE 'NOT FIRED' END AS status,
       CASE WHEN latest IS NOT NULL AND latest.value > t.threshold
            THEN t.action ELSE '' END AS triggered_action
ORDER BY status DESC;


// --- T5 · DEPENDENCIES at 2021-08-05 (switch result view to GRAPH) -----------
MATCH p1 = (:StrategicBet)-[:HAS_SCENARIO]->(sc:Scenario {id: 'scn_aggressive'})
           -[:REQUIRES]->(a:Assumption)-[:IF_FALSE_CAUSES]->(:Exposure)
MATCH p2 = (e:Evidence)-[:CONTRADICTS]->(a)
WHERE e.public_from <= date('2021-08-05')
RETURN p1, p2;
