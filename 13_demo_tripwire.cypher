// THE TRIPWIRE — threshold frozen on 10 Feb 2021, evaluated at both dates.
// Nothing in the graph stores whether it fired. That is computed here, now,
// against whatever evidence was public by each date.
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (t:Tripwire {id:'T_INVENTORY_1B'})
OPTIONAL MATCH (o:MetricObservation)
  WHERE o.metric = t.metric AND o.public_from <= cutoff
WITH cutoff, t, o
RETURN cutoff AS assessed_on,
       t.name AS tripwire,
       t.frozen_at AS threshold_frozen_on,
       t.threshold_value AS threshold_usd_m,
       o.value AS observed_usd_m,
       CASE WHEN o IS NULL THEN 'nothing public yet to test against'
            WHEN o.value > t.threshold_value THEN 'FIRED  ->  ' + t.action
            ELSE 'not fired' END AS outcome
ORDER BY assessed_on;
