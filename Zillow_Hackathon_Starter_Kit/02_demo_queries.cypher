// ZILLOW STRATEGY TIME MACHINE — DEMO QUERIES
// Run each query separately in Neo4j Browser / Workspace.

// ------------------------------------------------------------
// QUERY 1 — THE HERO: SHOW THE GRAPH AS KNOWN AT A CUTOFF
// ------------------------------------------------------------
// First use 2021-02-10. Then change only the date to 2021-08-05.

:param cutoff => '2021-02-10';

MATCH (b:StrategicBet {id:'BET_SCALE'})-[:CONSIDERS]->(s:Scenario)
MATCH (s)-[:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[:BEARS_ON]->(a)
WHERE e.public_from <= date($cutoff)
OPTIONAL MATCH (a)-[:FAILURE_EXPOSES]->(x:Exposure)
RETURN b, s, a, e, x
LIMIT 100;

// DEMO MOVE: change the parameter and rerun the same query.
:param cutoff => '2021-08-05';

// ------------------------------------------------------------
// QUERY 2 — RANK ASSUMPTIONS AT THE CURRENT CUTOFF
// Higher risk_signal means more decision attention is needed.
// An assumption with no eligible evidence receives an uncertainty penalty.
// ------------------------------------------------------------

MATCH (s:Scenario {id:'S_AGGRESSIVE'})-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
WHERE e.public_from <= date($cutoff)
WITH a, d,
     count(e) AS evidence_count,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS evidence_balance,
     collect(CASE WHEN e IS NULL THEN null ELSE e.title END) AS evidence_titles
WITH a, evidence_count, evidence_balance, evidence_titles,
     d.criticality *
       (CASE WHEN evidence_balance < 0 THEN abs(evidence_balance) ELSE 0 END +
        CASE WHEN evidence_count = 0 THEN 2 ELSE 0 END) AS risk_signal
RETURN a.name AS assumption,
       evidence_count,
       evidence_balance,
       risk_signal,
       evidence_titles
ORDER BY risk_signal DESC, assumption;

// ------------------------------------------------------------
// QUERY 3 — FIND THE MOST IMPORTANT UNKNOWNS
// This is a feature, not a failure: insufficient evidence is explicit.
// ------------------------------------------------------------

MATCH (s:Scenario {id:'S_AGGRESSIVE'})-[d:DEPENDS_ON]->(a:Assumption)
WHERE NOT EXISTS {
  MATCH (e:Evidence)-[:BEARS_ON]->(a)
  WHERE e.public_from <= date($cutoff)
}
RETURN a.name AS unsupported_assumption,
       d.criticality AS decision_criticality,
       'INSUFFICIENT EVIDENCE' AS state
ORDER BY decision_criticality DESC;

// ------------------------------------------------------------
// QUERY 4 — COMPARE A/B/C SCENARIOS
// This is a transparent prototype score, not a forecast probability.
// ------------------------------------------------------------

MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
WHERE e.public_from <= date($cutoff)
WITH s, a, d,
     count(e) AS evidence_count,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS evidence_balance
WITH s,
     sum(
       d.criticality *
       (CASE WHEN evidence_balance < 0 THEN abs(evidence_balance) ELSE 0 END +
        CASE WHEN evidence_count = 0 THEN 2 ELSE 0 END)
     ) AS structural_risk_signal,
     collect({assumption:a.name, balance:evidence_balance, evidence_count:evidence_count}) AS detail
RETURN s.name AS scenario,
       structural_risk_signal,
       detail
ORDER BY structural_risk_signal ASC;

// ------------------------------------------------------------
// QUERY 5 — SHOW THE MULTI-HOP PATH THAT JUSTIFIES ACTION
// ------------------------------------------------------------

MATCH path =
  (e:Evidence {id:'E_Q2_INVENTORY'})-[:BEARS_ON]->
  (a:Assumption)-[:FAILURE_EXPOSES]->
  (x:Exposure)
MATCH (s:Scenario {id:'S_AGGRESSIVE'})-[:DEPENDS_ON]->(a)
RETURN e, a, x, s, path;

// ------------------------------------------------------------
// QUERY 6 — EVALUATE THE FROZEN TRIPWIRE
// At 2021-02-10 it returns NO ELIGIBLE OBSERVATION.
// At 2021-08-05 it returns TRIGGERED.
// ------------------------------------------------------------

MATCH (t:Tripwire {id:'T_INVENTORY_1B'})-[:MONITORS]->(x:Exposure)
OPTIONAL MATCH (o:MetricObservation)-[:MEASURES]->(x)
WHERE o.metric = t.metric AND o.public_from <= date($cutoff)
RETURN t.name AS tripwire,
       t.frozen_at AS frozen_at,
       t.threshold_value AS threshold_usd_m,
       o.value AS observed_usd_m,
       CASE
         WHEN o IS NULL THEN 'NO ELIGIBLE OBSERVATION'
         WHEN o.value > t.threshold_value THEN 'TRIGGERED: ' + t.action
         ELSE 'NOT TRIGGERED'
       END AS state,
       t.note AS threshold_caveat;

// ------------------------------------------------------------
// QUERY 7 — SOURCE TRACEABILITY FOR ANY EVIDENCE NODE
// ------------------------------------------------------------

MATCH (e:Evidence)-[r:BEARS_ON]->(a:Assumption)
WHERE e.public_from <= date($cutoff)
RETURN e.public_from AS public_from,
       e.title AS evidence,
       e.claim AS claim,
       r.reason AS why_it_matters,
       a.name AS assumption,
       e.source_url AS source
ORDER BY public_from, evidence;

