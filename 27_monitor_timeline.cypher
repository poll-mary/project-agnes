// =============================================================================
// 27_monitor_timeline.cypher — WHEN DID AGNES LEARN THINGS, AND FROM WHOM?
// Replaces 21_signals.cypher, which predated the unified model.
//
// Sweeps every date anything became knowable and reports, at each one, what
// Agnes knew about the forecasting assumption from the company versus from the
// world. Supersession honoured.
// =============================================================================

MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine'
WITH collect(DISTINCT e.public_from) AS dates
UNWIND dates AS cut

OPTIONAL MATCH (arrived:Evidence)
  WHERE arrived.project = 'zillow_strategy_time_machine' AND arrived.public_from = cut
WITH cut, [x IN collect(arrived.title) WHERE x IS NOT NULL][0] AS headline,
     count(arrived) AS n_new,
     [x IN collect(DISTINCT arrived.origin) WHERE x IS NOT NULL] AS origins

OPTIONAL MATCH (ei:Evidence {origin:'INTERNAL'})-[ri:BEARS_ON]->(:Assumption {id:'A_FORECAST'})
  WHERE ei.public_from <= cut AND (ei.public_until IS NULL OR ei.public_until > cut)
WITH cut, headline, n_new, origins, count(ei) AS i_n

OPTIONAL MATCH (ex:Evidence {origin:'EXTERNAL'})-[rx:BEARS_ON]->(:Assumption {id:'A_FORECAST'})
  WHERE ex.public_from <= cut AND (ex.public_until IS NULL OR ex.public_until > cut)
WITH cut, headline, n_new, origins, i_n, count(ex) AS x_n,
     sum(CASE WHEN ex IS NULL THEN 0 ELSE rx.direction * rx.weight END) AS x_bal

OPTIONAL MATCH (rec:Evidence {origin:'EXTERNAL', declares_record:true})
  WHERE rec.public_from <= cut AND (rec.public_until IS NULL OR rec.public_until > cut)
WITH cut, headline, n_new, origins, i_n, x_n, x_bal, count(rec) AS records

RETURN cut AS on_date,
       n_new AS items, origins,
       left(coalesce(headline,''), 46) AS what_arrived,
       CASE WHEN i_n = 0 THEN 'SILENT' ELSE toString(i_n) + ' items' END AS company_says,
       CASE WHEN x_n = 0 THEN 'silent'
            ELSE toString(x_n) + ' items, balance ' + toString(x_bal) END AS world_says,
       CASE WHEN records > 0 THEN 'OUTSIDE_CALIBRATED_RANGE' ELSE '' END AS regime_flag
ORDER BY on_date;
