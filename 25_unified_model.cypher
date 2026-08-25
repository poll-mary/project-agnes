// =============================================================================
// 25_unified_model.cypher — ONE EVIDENCE MODEL, TWO ORIGINS
//
// Fixes two design faults:
//
// FAULT 1 · Two parallel external structures that did not know about each
//   other (WorldIndicator/IndicatorReading vs Evidence). Case-Shiller existed
//   in both. Now: ONE Evidence type, with `origin` separating the company's
//   own disclosures from the world around it. Separate at the source, merge at
//   the assumption - which is where they genuinely combine.
//
// FAULT 2 · No supersession. A market index reading is a statement about
//   CURRENT conditions - the next release replaces it. A quarterly filing is a
//   PERMANENT fact about a period. Treating both as accumulating means a
//   monthly series drowns everything else. Now:
//     kind = 'FACT'    -> accumulates, public_until stays null
//     kind = 'READING' -> superseded, public_until = next release in the series
//
// ELIGIBILITY PREDICATE, from here on, everywhere:
//     public_from <= cutoff AND (public_until IS NULL OR public_until > cutoff)
// =============================================================================

// --- 1. Retire the parallel structure ---------------------------------------
MATCH (r:IndicatorReading) DETACH DELETE r;


// --- 2. Classify everything already in the graph ----------------------------
MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine'
SET e.origin = CASE WHEN e.evidence_class = 'EXTERNAL_CONTEXT'
                    THEN 'EXTERNAL' ELSE 'INTERNAL' END,
    e.kind = CASE WHEN e.evidence_class = 'EXTERNAL_CONTEXT'
                  THEN 'READING' ELSE 'FACT' END;

// Opendoor's quarterly result is a permanent fact about a period, not a
// reading of current conditions. It does not get superseded.
MATCH (e:Evidence {id:'X_OPENDOOR_Q1'}) SET e.kind = 'FACT';


// --- 3. The Case-Shiller series, as Evidence, with the record flag ----------
UNWIND [
  {id:'X_CS_2021_01', public_from:'2021-01-26', declares_record:false, value:9.5,
   title:'Case-Shiller: national prices +9.5% annual, up from 8.4%',
   claim:'S&P CoreLogic Case-Shiller US National Home Price Index rose 9.5% annually in November 2020, up from 8.4%.',
   url:'https://press.spglobal.com/2021-01-26-S-P-CoreLogic-Case-Shiller-Index-Shows-Annual-Home-Price-Gains-Climbed-To-9-5-In-November'},
  {id:'X_CS_2021_07', public_from:'2021-07-27', declares_record:true, value:16.6,
   title:'Case-Shiller: RECORD HIGH annual home price gain of 16.6%',
   claim:'S&P titled their own release "Record High Annual Home Price Gain Of 16.6% In May" - the publisher declares the extreme, not us.',
   url:'https://press.spglobal.com/2021-07-27-S-P-CoreLogic-Case-Shiller-Index-Reports-Record-High-Annual-Home-Price-Gain-Of-16-6-In-May'}
] AS row
MERGE (e:Evidence {id: row.id})
SET e.project = 'zillow_strategy_time_machine',
    e.origin = 'EXTERNAL', e.kind = 'READING',
    e.public_from = date(row.public_from),
    e.title = row.title, e.claim = row.claim,
    e.publisher = 'S&P Dow Jones Indices',
    e.value = row.value, e.unit = 'percent_yoy',
    e.declares_record = row.declares_record,
    e.source_url = row.url,
    e.verification_status = 'primary_source_verified';


// --- 4. Supersession: each reading is replaced by the next in its series ----
// public_until = the public_from of the next reading WE HOLD. Honest: it says
// "superseded by the next reading in our data", not a claim about release
// calendars we have not verified.
UNWIND [
  {id:'X_CS_2020_12',    until:'2021-01-26'},
  {id:'X_CS_2021_01',    until:'2021-07-27'},
  {id:'X_NAR_2021_01',   until:'2021-07-22'},
  {id:'X_BEIGE_2021_01', until:'2021-07-14'}
] AS row
MATCH (e:Evidence {id: row.id}) SET e.public_until = date(row.until);

// Everything else is current: no successor in our data.
MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine' AND e.public_until IS NULL
SET e.public_until = null;


// --- 5. The Case-Shiller readings bear on assumptions, both directions ------
UNWIND [
  {e:'X_CS_2021_01', a:'A_DEMAND',   dir:1,  w:1, why:'Accelerating prices indicate strong near-term resale conditions.'},
  {e:'X_CS_2021_01', a:'A_FORECAST', dir:-1, w:1, why:'Appreciation running well above long-run norms widens forward forecast error.'},
  {e:'X_CS_2021_07', a:'A_DEMAND',   dir:1,  w:1, why:'Record appreciation means held inventory gains value while held.'},
  {e:'X_CS_2021_07', a:'A_FORECAST', dir:-1, w:2, why:'The publisher calls this a record: a forward price model has no training data for this regime. Exposure is protected by conditions that cannot persist.'}
] AS row
MATCH (e:Evidence {id: row.e}), (a:Assumption {id: row.a})
MERGE (e)-[r:BEARS_ON]->(a)
SET r.direction = row.dir, r.weight = row.w, r.reason = row.why;


// --- 6. Link external evidence to the series it belongs to ------------------
UNWIND [
  {e:'X_CS_2020_12', i:'IND_HPA'}, {e:'X_CS_2021_01', i:'IND_HPA'}, {e:'X_CS_2021_07', i:'IND_HPA'},
  {e:'X_NAR_2021_01', i:'IND_MONTHS_SUPPLY'}, {e:'X_NAR_2021_07', i:'IND_MONTHS_SUPPLY'},
  {e:'X_PMMS_2021_02', i:'IND_MORTGAGE_RATE'},
  {e:'X_BEIGE_2021_01', i:'IND_CONSTRUCTION_LABOR'}, {e:'X_BEIGE_2021_07', i:'IND_CONSTRUCTION_LABOR'}
] AS row
MATCH (e:Evidence {id: row.e}), (i:WorldIndicator {id: row.i})
MERGE (e)-[:FROM_SERIES]->(i);

// Those series now have data. Mark them loaded; the rest keep their holes visible.
MATCH (i:WorldIndicator)<-[:FROM_SERIES]-(:Evidence) SET i.status = 'LOADED';


// --- 7. Check ---------------------------------------------------------------
MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine'
RETURN e.origin AS origin, e.kind AS kind, count(e) AS items,
       sum(CASE WHEN e.public_until IS NOT NULL THEN 1 ELSE 0 END) AS superseded
ORDER BY origin, kind;
