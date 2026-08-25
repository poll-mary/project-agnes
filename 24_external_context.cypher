// =============================================================================
// 24_external_context.cypher — THE WORLD ZILLOW WAS OPERATING IN
//
// Sourced by Mary. Dates and publishers as cited; CC has NOT independently
// re-verified every citation — each node carries verification_status so that
// is visible rather than assumed.
//
// TWO RULES ENFORCED HERE:
//
// 1. DUAL BEARING. The same fact may support one assumption and challenge
//    another. A record-hot market supports resale demand AND challenges
//    forecast reliability. Both edges exist, with opposite directions.
//
// 2. MARKET VELOCITY IS NOT ZILLOW VELOCITY. National homes selling in 17 days
//    does NOT prove Zillow could resell in 17 days. Market-wide speed bears on
//    DEMAND. It never bears on A_THROUGHPUT, which needs Zillow-specific
//    renovation and holding data we do not have.
// =============================================================================

// --- Evidence knowable by 10 February 2021 ----------------------------------
UNWIND [
  {id:'X_CS_2020_12', public_from:'2020-12-29',
   title:'Case-Shiller: national prices +8.4% annual, accelerating from 7.0%',
   claim:'National home prices rose 8.4% annually, accelerating from 7.0% the prior month.',
   publisher:'S&P Dow Jones Indices'},
  {id:'X_NAR_2021_01', public_from:'2021-01-22',
   title:'NAR: inventory 1.07m, 1.9 months supply (all-time low), 21 days on market',
   claim:'Existing-home inventory 1.07 million, a record-low 1.9 months of supply; homes typically sold in 21 days.',
   publisher:'National Association of Realtors'},
  {id:'X_PMMS_2021_02', public_from:'2021-02-04',
   title:'Freddie Mac: 30-year fixed mortgage ~2.73%',
   claim:'Thirty-year fixed mortgage rate approximately 2.73%.',
   publisher:'Freddie Mac PMMS'},
  {id:'X_BEIGE_2021_01', public_from:'2021-01-13',
   title:'Fed Beige Book: rising lumber and construction costs, labour shortages, delivery and permitting delays',
   claim:'Districts reported rising lumber and construction costs, labour shortages, appliance and material delays, and permitting delays.',
   publisher:'Federal Reserve Beige Book'},
  // --- Evidence knowable by 5 August 2021 -----------------------------------
  {id:'X_OPENDOOR_Q1', public_from:'2021-05-11',
   title:'Opendoor Q1 2021: 2,462 homes sold, 3,594 purchased, 13% gross margin',
   claim:'Competitor sold 2,462 and purchased 3,594 homes at 13% gross margin, having stated margins benefited from home-price appreciation and were expected to moderate as inventory rebuilt.',
   publisher:'Opendoor Technologies'},
  {id:'X_NAR_2021_07', public_from:'2021-07-22',
   title:'NAR: prices +23.4% annual, 2.6 months supply, 17 days on market',
   claim:'Median prices up 23.4% annually, supply 2.6 months, homes typically sold in 17 days.',
   publisher:'National Association of Realtors'},
  {id:'X_BEIGE_2021_07', public_from:'2021-07-14',
   title:'Fed Beige Book: material and labour shortages increasingly widespread',
   claim:'Material and labour shortages, delivery delays and elevated construction costs reported as increasingly widespread.',
   publisher:'Federal Reserve Beige Book'},
  {id:'X_REDFIN_2021_07', public_from:'2021-07-30',
   title:'Redfin: homebuyer demand softening, smallest pending-sales increase since early pandemic',
   claim:'Softening homebuyer demand and the smallest pending-sales increase since early in the pandemic, with prices still supported by low rates.',
   publisher:'Redfin'}
] AS row
MERGE (e:Evidence {id: row.id})
SET e.project = 'zillow_strategy_time_machine',
    e.public_from = date(row.public_from),
    e.title = row.title, e.claim = row.claim,
    e.publisher = row.publisher,
    e.evidence_class = 'EXTERNAL_CONTEXT',
    e.verification_status = 'cited_by_user_not_independently_reverified';


// --- Bearings. Note the deliberate contradictions. ---------------------------
UNWIND [
  // Accelerating prices: good for resale now, bad for forecast calibration.
  {e:'X_CS_2020_12', a:'A_DEMAND',     dir:1,  w:1, why:'Accelerating prices indicate strong near-term resale conditions.'},
  {e:'X_CS_2020_12', a:'A_FORECAST',   dir:-1, w:1, why:'Acceleration away from long-run norms widens forward forecast error; strategy increasingly depends on appreciation continuing.'},

  // Tight market: demand only. NOT throughput - market speed is not Zillow speed.
  {e:'X_NAR_2021_01', a:'A_DEMAND',    dir:1,  w:2, why:'Record-low supply and 21-day sale times show strong buyer demand and market liquidity.'},
  {e:'X_NAR_2021_01', a:'A_FORECAST',  dir:-1, w:1, why:'A market at record-low supply is an abnormal regime; pricing models calibrated on normal conditions face unknown error.'},

  {e:'X_PMMS_2021_02', a:'A_DEMAND',   dir:1,  w:1, why:'Cheap financing supports buyer demand.'},

  // Beige Book: the operational warning, available at T0, from OUTSIDE Zillow.
  {e:'X_BEIGE_2021_01', a:'A_THROUGHPUT', dir:-1, w:2, why:'Labour shortages, material delays and permitting delays directly constrain renovation and resale throughput.'},
  {e:'X_BEIGE_2021_01', a:'A_UNIT',       dir:-1, w:1, why:'Rising construction and material costs compress per-home economics.'},

  // Competitor: iBuying is feasible - but the competitor said margins depend on appreciation.
  {e:'X_OPENDOOR_Q1', a:'A_UNIT',      dir:1,  w:1, why:'A competitor achieved 13% gross margin, so iBuying unit economics are not inherently impossible.'},
  {e:'X_OPENDOOR_Q1', a:'A_FORECAST',  dir:-1, w:2, why:'Competitor stated margins benefited from home-price appreciation and were expected to moderate - the economics depend on the forecast regime persisting.'},
  {e:'X_OPENDOOR_Q1', a:'A_THROUGHPUT', dir:-1, w:1, why:'Competitor purchased 3,594 against 2,462 sold: acquisition outpacing resale is an industry-wide pattern, not Zillow-specific.'},

  {e:'X_NAR_2021_07', a:'A_DEMAND',    dir:1,  w:2, why:'17-day sale times and 2.6 months supply confirm an exceptional market tailwind.'},
  {e:'X_NAR_2021_07', a:'A_FORECAST',  dir:-1, w:2, why:'23.4% annual price growth is far outside any calibration range; exposure is protected by conditions that cannot persist.'},

  {e:'X_BEIGE_2021_07', a:'A_THROUGHPUT', dir:-1, w:2, why:'Shortages and delays increasingly widespread - renovation capacity constraint worsening, from external reporting.'},
  {e:'X_BEIGE_2021_07', a:'A_UNIT',       dir:-1, w:1, why:'Elevated construction costs persisting.'},

  {e:'X_REDFIN_2021_07', a:'A_DEMAND',   dir:-1, w:1, why:'Early demand moderation: the tailwind protecting the strategy may be starting to weaken.'}
] AS row
MATCH (e:Evidence {id: row.e}), (a:Assumption {id: row.a})
MERGE (e)-[r:BEARS_ON]->(a)
SET r.direction = row.dir, r.weight = row.w, r.reason = row.why;


// --- The dual-bearing view: one fact, two opposite conclusions ---------------
MATCH (e:Evidence {evidence_class:'EXTERNAL_CONTEXT'})-[r:BEARS_ON]->(a:Assumption)
WITH e, collect({assumption:a.name, direction:r.direction, why:r.reason}) AS bearings
WHERE size(bearings) > 1
RETURN e.public_from AS published,
       left(e.title, 60) AS external_signal,
       [b IN bearings WHERE b.direction = 1  | b.assumption] AS supports,
       [b IN bearings WHERE b.direction = -1 | b.assumption] AS challenges
ORDER BY published;
