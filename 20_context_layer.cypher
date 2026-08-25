// =============================================================================
// 20_context_layer.cypher — AGNES LOOKS OUTSIDE THE COMPANY
//
// THE RULE HAS NO NUMBERS IN IT.
// Agnes does not compute what counts as extreme. The publisher declares it.
// S&P titled their 27 Jul 2021 release "Record High Annual Home Price Gain".
// Agnes reads that flag. No threshold, no lookback, no multiplier, no direction.
//
// A declared record means: a model calibrated on history has no data for this
// regime. That is a statement about UNCERTAINTY, not about good or bad.
// Record appreciation is good for holding margin and bad for forecast
// calibration at the same time. Agnes does not have to pick a side.
// =============================================================================

CREATE CONSTRAINT indicator_id IF NOT EXISTS
FOR (n:WorldIndicator) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT reading_id IF NOT EXISTS
FOR (n:IndicatorReading) REQUIRE n.id IS UNIQUE;


// --- 1. The panel -----------------------------------------------------------
// Derived from the operating model of a business that BUYS, RENOVATES and
// RESELLS houses. Declared as a whole. Indicators we could not source today
// stay in the graph marked NOT_LOADED so the holes are visible.
// Drafted by the coding agent, NOT reviewed by a domain expert. Marked as such.
UNWIND [
  {id:'IND_HPA', name:'Home price appreciation, US national, YoY %',
   publisher:'S&P Dow Jones Indices / CoreLogic Case-Shiller',
   informs:'A_FORECAST', status:'LOADED',
   rationale:'A forward resale-price model is calibrated on historical appreciation ranges.'},
  {id:'IND_MORTGAGE_RATE', name:'30-year fixed mortgage rate',
   publisher:'Freddie Mac PMMS', informs:'A_DEMAND', status:'NOT_LOADED',
   rationale:'Financing cost drives buyer demand and therefore resale speed.'},
  {id:'IND_MONTHS_SUPPLY', name:'Existing-home months of supply',
   publisher:'National Association of Realtors', informs:'A_THROUGHPUT', status:'NOT_LOADED',
   rationale:'Market absorption capacity for reselling held inventory.'},
  {id:'IND_DAYS_ON_MARKET', name:'Median days on market',
   publisher:'NAR / Realtor.com', informs:'A_THROUGHPUT', status:'NOT_LOADED',
   rationale:'How quickly held inventory can be cleared.'},
  {id:'IND_MATERIALS', name:'Building materials price (lumber)',
   publisher:'BLS PPI / CME', informs:'A_UNIT', status:'NOT_LOADED',
   rationale:'Renovation input cost per home, directly in unit economics.'},
  {id:'IND_CONSTRUCTION_LABOR', name:'Construction labour availability',
   publisher:'US Bureau of Labor Statistics', informs:'A_THROUGHPUT', status:'NOT_LOADED',
   rationale:'Renovation capacity constrains how fast acquisitions can be processed.'}
] AS row
MERGE (i:WorldIndicator {id: row.id})
SET i.project = 'zillow_strategy_time_machine',
    i.name = row.name, i.publisher = row.publisher,
    i.informs_rationale = row.rationale, i.status = row.status,
    i.proposed_by = 'CC_draft', i.reviewed = false
WITH i, row
MATCH (a:Assumption {id: row.informs})
MERGE (i)-[:INFORMS]->(a);


// --- 2. Readings — only what is verified to a dated primary source -----------
// publisher_declares_record is taken from the TITLE of the release itself.
// It is not our judgement.
UNWIND [
  {id:'READ_HPA_2021_01', indicator:'IND_HPA',
   value:9.5, valid_at:'2020-11-30', public_from:'2021-01-26',
   record:false,
   headline:'S&P CoreLogic Case-Shiller Index Shows Annual Home Price Gains Climbed To 9.5% In November',
   url:'https://press.spglobal.com/2021-01-26-S-P-CoreLogic-Case-Shiller-Index-Shows-Annual-Home-Price-Gains-Climbed-To-9-5-In-November'},
  {id:'READ_HPA_2021_07', indicator:'IND_HPA',
   value:16.6, valid_at:'2021-05-31', public_from:'2021-07-27',
   record:true,
   headline:'S&P CoreLogic Case-Shiller Index Reports Record High Annual Home Price Gain Of 16.6% In May',
   url:'https://press.spglobal.com/2021-07-27-S-P-CoreLogic-Case-Shiller-Index-Reports-Record-High-Annual-Home-Price-Gain-Of-16-6-In-May'}
] AS row
MERGE (r:IndicatorReading {id: row.id})
SET r.project = 'zillow_strategy_time_machine',
    r.value = row.value, r.unit = 'percent_yoy',
    r.valid_at = date(row.valid_at),
    r.public_from = date(row.public_from),
    r.publisher_declares_record = row.record,
    r.publisher_headline = row.headline,
    r.source_url = row.url
WITH r, row
MATCH (i:WorldIndicator {id: row.indicator})
MERGE (i)-[:HAS_READING]->(r);


// --- 3. Coverage report — Agnes states her own blind spots -------------------
MATCH (i:WorldIndicator)-[:INFORMS]->(a:Assumption)
OPTIONAL MATCH (i)-[:HAS_READING]->(r:IndicatorReading)
WITH i, a, count(r) AS readings
RETURN i.status AS status,
       i.name AS should_be_watching,
       a.name AS informs_assumption,
       readings AS readings_held,
       CASE WHEN i.reviewed THEN 'reviewed' ELSE 'PANEL NOT REVIEWED BY DOMAIN EXPERT' END AS caveat
ORDER BY status, should_be_watching;
