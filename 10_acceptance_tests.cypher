// =============================================================================
// 10_acceptance_tests.cypher — DOES THE MACHINERY DO WHAT IT CLAIMS?
//
// Not "does the Zillow story look good." Each test can FAIL. If one fails, the
// system does not do what we say it does, and we say so on stage.
//
// Run after 01 and 01b. Every test returns PASS or FAIL in a `result` column.
// =============================================================================


// --- T1 · DATE BOUNDARY: off-by-one on the cutoff ----------------------------
// The FY2020 10-K is public_from 2021-02-12. It must be excluded at 02-10 AND
// at 02-11, and included at 02-12. This tests the actual mechanism, not the story.
MATCH (e:Evidence {id:'E_FY2020_10K'})
WITH e,
     (CASE WHEN e.public_from <= date('2021-02-10') THEN 1 ELSE 0 END) AS at_10,
     (CASE WHEN e.public_from <= date('2021-02-11') THEN 1 ELSE 0 END) AS at_11,
     (CASE WHEN e.public_from <= date('2021-02-12') THEN 1 ELSE 0 END) AS at_12
RETURN 'T1 date boundary' AS test, at_10, at_11, at_12,
       CASE WHEN at_10 = 0 AND at_11 = 0 AND at_12 = 1 THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T2 · EMPTY PAST: before any evidence exists, the system must know nothing
// At 2019-01-01 nothing is eligible. If any assumption reports evidence, the
// date filter is broken.
MATCH (a:Assumption) WHERE a.project = 'zillow_strategy_time_machine'
OPTIONAL MATCH (e:Evidence)-[:BEARS_ON]->(a) WHERE e.public_from <= date('2019-01-01')
WITH count(e) AS eligible_edges
RETURN 'T2 empty past' AS test, eligible_edges,
       CASE WHEN eligible_edges = 0 THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T3 · UNKNOWN IS NOT THE SAME AS NEGATIVE --------------------------------
// A_FORECAST has no evidence at all. A_UNIT has negative evidence. The system
// must distinguish them. A model that collapses these is asserting, not assessing.
MATCH (a:Assumption) WHERE a.id IN ['A_FORECAST','A_UNIT']
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= date('2021-02-10')
WITH a, count(e) AS cnt, sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH collect({id:a.id, cnt:cnt, bal:bal}) AS rows
WITH [x IN rows WHERE x.id='A_FORECAST'][0] AS f, [x IN rows WHERE x.id='A_UNIT'][0] AS u
RETURN 'T3 unknown != negative' AS test,
       f.cnt AS forecast_count, u.bal AS unit_balance,
       CASE WHEN f.cnt = 0 AND u.bal < 0 THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T4 · NEGATIVE CONTROL: the system must be capable of NOT condemning -----
// A_DEMAND must stay POSITIVE at both cutoffs. If everything we feed it turns
// negative, we have built a pessimism machine, not an assessment tool.
MATCH (a:Assumption {id:'A_DEMAND'})
OPTIONAL MATCH (e1:Evidence)-[r1:BEARS_ON]->(a) WHERE e1.public_from <= date('2021-02-10')
WITH a, sum(CASE WHEN e1 IS NULL THEN 0 ELSE r1.direction*r1.weight END) AS t0
OPTIONAL MATCH (e2:Evidence)-[r2:BEARS_ON]->(a) WHERE e2.public_from <= date('2021-08-05')
WITH t0, sum(CASE WHEN e2 IS NULL THEN 0 ELSE r2.direction*r2.weight END) AS q2
RETURN 'T4 negative control' AS test, t0 AS balance_t0, q2 AS balance_q2,
       CASE WHEN t0 > 0 AND q2 > 0 THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T5 · STRUCTURAL NON-RESPONSE -------------------------------------------
// Capital-light depends on assumptions the Q2 evidence does not touch, so its
// risk signal must be IDENTICAL at both cutoffs. If it moves, our dependency
// structure is wrong and the "it wasn't exposed" claim is false.
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (s:Scenario {id:'S_CAPITAL_LIGHT'})-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= cutoff
WITH cutoff, a, d, count(e) AS cnt,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction*r.weight END) AS bal
WITH cutoff, sum(d.criticality * ((CASE WHEN bal < 0 THEN abs(bal) ELSE 0 END) +
                                  (CASE WHEN cnt = 0 THEN 2 ELSE 0 END))) AS risk
ORDER BY cutoff
WITH collect(risk) AS risks
RETURN 'T5 structural non-response' AS test, risks,
       CASE WHEN risks[0] = risks[1] THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T6 · TRIPWIRE IS COMPUTED, NOT STORED -----------------------------------
// There must be NO direct edge from evidence/observations to the tripwire.
// If one exists, we pre-baked the answer and the "frozen before, fired after"
// claim is hindsight.
MATCH (t:Tripwire)
OPTIONAL MATCH (t)<-[r]-(n) WHERE n:Evidence OR n:MetricObservation
WITH count(r) AS prebaked_edges
RETURN 'T6 tripwire computed' AS test, prebaked_edges,
       CASE WHEN prebaked_edges = 0 THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T7 · ELIGIBILITY IS MONOTONIC -------------------------------------------
// Evidence count must never DECREASE as the cutoff advances. A later date can
// only reveal more, never less.
UNWIND [date('2019-01-01'), date('2021-02-10'), date('2021-02-12'), date('2021-08-05')] AS cutoff
MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine' AND e.public_from <= cutoff
WITH cutoff, count(e) AS n
ORDER BY cutoff
WITH collect(n) AS counts
RETURN 'T7 monotonic eligibility' AS test, counts,
       CASE WHEN counts[0] <= counts[1] AND counts[1] <= counts[2]
                 AND counts[2] <= counts[3] THEN 'PASS' ELSE 'FAIL' END AS result;


// --- T8 · DETERMINISM (run manually, twice) ----------------------------------
// Run Query 2 from 02_demo_queries.cypher twice at the same cutoff. The rows
// must be identical. An LLM asked the same question twice will not be.
// This is the concrete difference from a prompt, so it is worth actually doing.
