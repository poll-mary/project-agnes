// THE CORE DEMO — same question, two dates, nothing else changed.
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (a:Assumption) WHERE a.project = 'zillow_strategy_time_machine'
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= cutoff
WITH cutoff, a, count(e) AS cnt,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH cutoff, a,
     CASE WHEN cnt = 0 THEN 'NOT EVIDENCED'
          WHEN bal > 0 THEN 'supported'
          WHEN bal = 0 THEN 'mixed'
          ELSE 'CHALLENGED' END + ' (' + toString(bal) + ')' AS state
WITH a.name AS must_be_true,
     max(CASE WHEN cutoff = date('2021-02-10') THEN state END) AS on_10_feb,
     max(CASE WHEN cutoff = date('2021-08-05') THEN state END) AS on_05_aug
RETURN must_be_true, on_10_feb, on_05_aug,
       CASE WHEN on_10_feb = on_05_aug THEN '' ELSE '<<< CHANGED' END AS moved
ORDER BY moved DESC, must_be_true;
