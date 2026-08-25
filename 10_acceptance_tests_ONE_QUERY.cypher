// ALL ACCEPTANCE TESTS IN ONE QUERY. Paste, run, read the result column.
// Each test can FAIL. A failure means the machinery does not do what we claim.

MATCH (e:Evidence {id:'E_FY2020_10K'})
WITH (CASE WHEN e.public_from <= date('2021-02-10') THEN 1 ELSE 0 END) AS a10,
     (CASE WHEN e.public_from <= date('2021-02-11') THEN 1 ELSE 0 END) AS a11,
     (CASE WHEN e.public_from <= date('2021-02-12') THEN 1 ELSE 0 END) AS a12
RETURN 'T1  10-K stays invisible until the day it was filed' AS test,
       'visible on 10th/11th/12th Feb: '+toString(a10)+'/'+toString(a11)+'/'+toString(a12) AS detail,
       CASE WHEN a10=0 AND a11=0 AND a12=1 THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL
MATCH (a:Assumption) WHERE a.project='zillow_strategy_time_machine'
OPTIONAL MATCH (e:Evidence)-[:BEARS_ON]->(a) WHERE e.public_from <= date('2019-01-01')
WITH count(e) AS n
RETURN 'T2  in 2019 the graph knows nothing' AS test,
       toString(n)+' pieces of evidence eligible (must be 0)' AS detail,
       CASE WHEN n=0 THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL
MATCH (a:Assumption) WHERE a.id IN ['A_FORECAST','A_UNIT']
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= date('2021-02-10')
WITH a, count(e) AS cnt, sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction*r.weight END) AS bal
WITH collect({id:a.id,cnt:cnt,bal:bal}) AS rows
WITH [x IN rows WHERE x.id='A_FORECAST'][0] AS f, [x IN rows WHERE x.id='A_UNIT'][0] AS u
RETURN 'T3  "we do not know" is not the same as "this is bad"' AS test,
       'forecasting has '+toString(f.cnt)+' evidence; unit economics scores '+toString(u.bal) AS detail,
       CASE WHEN f.cnt=0 AND u.bal<0 THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL
MATCH (a:Assumption {id:'A_DEMAND'})
OPTIONAL MATCH (e1:Evidence)-[r1:BEARS_ON]->(a) WHERE e1.public_from <= date('2021-02-10')
WITH a, sum(CASE WHEN e1 IS NULL THEN 0 ELSE r1.direction*r1.weight END) AS t0
OPTIONAL MATCH (e2:Evidence)-[r2:BEARS_ON]->(a) WHERE e2.public_from <= date('2021-08-05')
WITH t0, sum(CASE WHEN e2 IS NULL THEN 0 ELSE r2.direction*r2.weight END) AS q2
RETURN 'T4  the graph is not just pessimistic (demand holds)' AS test,
       'demand scores '+toString(t0)+' in Feb, '+toString(q2)+' in Aug (both must be positive)' AS detail,
       CASE WHEN t0>0 AND q2>0 THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (s:Scenario {id:'S_CAPITAL_LIGHT'})-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= cutoff
WITH cutoff, a, d, count(e) AS cnt,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction*r.weight END) AS bal
WITH cutoff, sum(d.criticality * ((CASE WHEN bal<0 THEN abs(bal) ELSE 0 END) +
                                  (CASE WHEN cnt=0 THEN 2 ELSE 0 END))) AS risk
ORDER BY cutoff
WITH collect(risk) AS risks
RETURN 'T5  capital-light unmoved by evidence it does not depend on' AS test,
       'scores '+toString(risks[0])+' in Feb, '+toString(risks[1])+' in Aug (must be identical)' AS detail,
       CASE WHEN risks[0]=risks[1] THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL
MATCH (t:Tripwire)
OPTIONAL MATCH (t)<-[r]-(n) WHERE n:Evidence OR n:MetricObservation
WITH count(r) AS n
RETURN 'T6  tripwire is calculated, never pre-stored' AS test,
       toString(n)+' pre-baked links found (must be 0)' AS detail,
       CASE WHEN n=0 THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL
UNWIND [date('2019-01-01'), date('2021-02-10'), date('2021-02-12'), date('2021-08-05')] AS cutoff
OPTIONAL MATCH (e:Evidence)
  WHERE e.project='zillow_strategy_time_machine' AND e.public_from <= cutoff
WITH cutoff, count(e) AS n
ORDER BY cutoff
WITH collect(n) AS c
RETURN 'T7  evidence only ever accumulates, never vanishes' AS test,
       'visible over time: '+toString(c) AS detail,
       CASE WHEN c[0]<=c[1] AND c[1]<=c[2] AND c[2]<=c[3] THEN 'PASS' ELSE 'FAIL' END AS result;
