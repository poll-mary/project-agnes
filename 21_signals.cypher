// =============================================================================
// 21_signals.cypher — DOES CONTEXT RAISE A SIGNAL THAT FILINGS DO NOT?
//
// Sweeps EVERY date on which anything became public — company filings and
// world-context releases alike — and reports, at each one:
//
//   what Agnes knows about A_FORECAST from company filings alone
//   what Agnes knows once she also watches the world
//
// A_FORECAST is the assumption Rich Barton named on 2 Nov 2021 as the reason
// the business closed: "the unpredictability in forecasting home prices far
// exceeds what we anticipated."
//
// No thresholds anywhere in this query. The only context test is whether the
// PUBLISHER declared a record in their own release title.
// =============================================================================

// Every date on which something became knowable.
MATCH (n)
WHERE n.project = 'zillow_strategy_time_machine' AND n.public_from IS NOT NULL
WITH collect(DISTINCT n.public_from) AS dates
UNWIND dates AS d

// What became public on that date.
OPTIONAL MATCH (arrived)
  WHERE arrived.project = 'zillow_strategy_time_machine' AND arrived.public_from = d
WITH d, [x IN collect(coalesce(arrived.title, arrived.publisher_headline))
           WHERE x IS NOT NULL][0] AS first_arrival,
        count(arrived) AS n_arrived

// What company filings say about the forecasting assumption, as at that date.
OPTIONAL MATCH (e:Evidence)-[:BEARS_ON]->(:Assumption {id:'A_FORECAST'})
  WHERE e.public_from <= d
WITH d, first_arrival, n_arrived, count(e) AS internal_evidence

// What the world says: has any indicator informing this assumption had a
// reading whose PUBLISHER called it a record, by this date?
OPTIONAL MATCH (i:WorldIndicator)-[:INFORMS]->(:Assumption {id:'A_FORECAST'}),
               (i)-[:HAS_READING]->(r:IndicatorReading)
  WHERE r.public_from <= d AND r.publisher_declares_record = true
WITH d, first_arrival, n_arrived, internal_evidence,
     count(r) AS records_declared,
     collect(r.publisher_headline)[0] AS record_headline

RETURN d AS on_date,
       n_arrived AS items_published,
       left(coalesce(first_arrival,''), 58) AS what_became_public,
       CASE WHEN internal_evidence = 0
            THEN 'silent - no evidence either way'
            ELSE toString(internal_evidence) + ' items' END AS from_company_filings,
       CASE WHEN records_declared = 0
            THEN 'silent'
            ELSE 'SIGNAL: OUTSIDE_CALIBRATED_RANGE' END AS with_world_context,
       CASE WHEN records_declared > 0 AND internal_evidence = 0
            THEN '<<< context sees what filings cannot'
            ELSE '' END AS finding
ORDER BY on_date;
