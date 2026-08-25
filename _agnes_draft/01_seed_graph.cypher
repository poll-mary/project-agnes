// =============================================================================
// PROJECT AGNES — 01_seed_graph.cypher
// A living decision graph. Zillow Offers, point-in-time.
//
// HOW TO RUN: paste the whole file into the Aura query editor and run.
// If multi-statement execution fails, run each numbered block on its own,
// top to bottom. Every block is idempotent (MERGE) — re-running is safe and
// is exactly what you do at 17:15 to prove reproducibility.
// =============================================================================


// --- 0. RESET (commented out on purpose — uncomment only if you must) --------
// MATCH (n) DETACH DELETE n;


// --- 1. Constraints ---------------------------------------------------------
CREATE CONSTRAINT bet_id       IF NOT EXISTS FOR (n:StrategicBet) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT scenario_id  IF NOT EXISTS FOR (n:Scenario)     REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT assumption_id IF NOT EXISTS FOR (n:Assumption)  REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT evidence_id  IF NOT EXISTS FOR (n:Evidence)     REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT exposure_id  IF NOT EXISTS FOR (n:Exposure)     REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT tripwire_id  IF NOT EXISTS FOR (n:Tripwire)     REQUIRE n.id IS UNIQUE;


// --- 2. The strategic bet and its alternative forms --------------------------
// capital_intensity is knowable at T0. It is a property of the scenario's
// structure, NOT of what happened. All REQUIRES weights derive from it.
MERGE (b:StrategicBet {id: 'bet_zillow_offers'})
SET b.name        = 'Scale Zillow Offers',
    b.description = 'Expand principal iBuying: buy homes directly, hold them, resell.',
    b.owner       = 'Zillow Group',
    b.opened_on   = date('2020-02-19')
WITH b
UNWIND [
  {id:'scn_aggressive',    name:'Aggressive principal',   form:'principal_ownership', capital_intensity:1.0,
   description:'Zillow buys and holds thousands of homes on its own balance sheet.'},
  {id:'scn_hybrid',        name:'Hybrid / partner',       form:'mixed',               capital_intensity:0.5,
   description:'Shared inventory risk with partners; smaller principal book.'},
  {id:'scn_capital_light', name:'Capital-light referral', form:'referral',            capital_intensity:0.1,
   description:'Monetise intent by routing sellers to partner buyers. No inventory held.'}
] AS row
MERGE (s:Scenario {id: row.id})
SET s.name = row.name, s.form = row.form,
    s.capital_intensity = row.capital_intensity, s.description = row.description
MERGE (b)-[:HAS_SCENARIO]->(s);


// --- 3. Assumptions — what must be true --------------------------------------
UNWIND [
  {id:'asm_forecast',   statement:'Forward home-price forecasting is accurate enough to price offers profitably.'},
  {id:'asm_throughput', statement:'Resale throughput keeps pace with the pace of acquisition.'},
  {id:'asm_liquidity',  statement:'Capital and liquidity can absorb the inventory build.'},
  {id:'asm_unit_econ',  statement:'Unit economics per home are positive at scale.'},
  {id:'asm_holding',    statement:'Holding costs stay bounded as inventory grows.'},
  {id:'asm_demand',     statement:'Consumer demand for instant cash offers exists at scale.'}
] AS row
MERGE (a:Assumption {id: row.id}) SET a.statement = row.statement;


// --- 4. Exposures — what it costs you if an assumption fails ------------------
UNWIND [
  {id:'exp_inventory', name:'Inventory and holding-cost exposure', severity:0.9},
  {id:'exp_writedown', name:'Forced price cuts and write-downs on held homes', severity:0.9},
  {id:'exp_liquidity', name:'Liquidity absorbed by unsold inventory', severity:0.8},
  {id:'exp_growth',    name:'Segment fails to scale', severity:0.5}
] AS row
MERGE (x:Exposure {id: row.id}) SET x.name = row.name, x.severity = row.severity;


// --- 5. Evidence — every node carries public_from. THIS IS THE BOUNDARY. ------
// public_from = the date this became publicly knowable. Queries filter on it.
// Note the correction: the FY2020 10-K was filed 2021-02-12, so it is NOT
// eligible at the 2021-02-10 checkpoint. Two days matter.
UNWIND [
  {id:'ev_10k2019',    public_from:date('2020-02-19'), metric:'',                       value:0.0,
   statement:'FY2019 Form 10-K: inventory and holding-cost exposure is structural to principal iBuying.',
   source:'SEC Form 10-K, Zillow Group, FY2019'},
  {id:'ev_mgmt_conf',  public_from:date('2021-02-10'), metric:'',                       value:0.0,
   statement:'Q4/FY2020 earnings release: management expresses confidence in scaling the Homes segment.',
   source:'Zillow Group Q4/FY2020 earnings release'},
  {id:'ev_homes_loss', public_from:date('2021-02-10'), metric:'homes_segment_loss_usd', value:320254000.0,
   statement:'Homes segment loss of $320.254m for FY2020.',
   source:'Zillow Group Q4/FY2020 earnings release'},
  {id:'ev_cash',       public_from:date('2021-02-10'), metric:'cash_and_investments_usd', value:3900000000.0,
   statement:'Cash and investments of approximately $3.9bn.',
   source:'Zillow Group Q4/FY2020 earnings release'},
  {id:'ev_10k2020',    public_from:date('2021-02-12'), metric:'',                       value:0.0,
   statement:'FY2020 Form 10-K filed; inventory and holding-cost risk factors restated.',
   source:'SEC Form 10-K, Zillow Group, FY2020'},
  {id:'ev_homes_sold', public_from:date('2021-08-05'), metric:'homes_sold_count',       value:2086.0,
   statement:'Q2 2021: 2,086 homes sold, $772m Homes segment revenue.',
   source:'SEC Form 10-Q, Zillow Group, Q2 2021'},
  {id:'ev_inventory',  public_from:date('2021-08-05'), metric:'homes_inventory_usd',    value:1169601000.0,
   statement:'Homes inventory $1.169601bn, against $491.293m in the prior period.',
   source:'SEC Form 10-Q, Zillow Group, Q2 2021'},
  {id:'ev_holding',    public_from:date('2021-08-05'), metric:'holding_costs_usd',      value:5300000.0,
   statement:'Holding costs $5.3m, against $2.6m in the prior period.',
   source:'SEC Form 10-Q, Zillow Group, Q2 2021'}
] AS row
MERGE (e:Evidence {id: row.id})
SET e.statement = row.statement, e.public_from = row.public_from,
    e.source = row.source, e.metric = row.metric, e.value = row.value,
    e.source_url = 'https://www.sec.gov/edgar/search/#/entityName=Zillow%20Group';


// --- 6. Which scenario depends on which assumption, and how hard --------------
// weight is derived from capital_intensity. Owning homes is what makes you
// dependent on throughput, liquidity and holding costs. Referral is not.
// Demand carries weight 1.0 everywhere: every form of the bet needs sellers.
UNWIND [
  {s:'scn_aggressive',    a:'asm_forecast',   w:1.0}, {s:'scn_aggressive',    a:'asm_throughput', w:1.0},
  {s:'scn_aggressive',    a:'asm_liquidity',  w:1.0}, {s:'scn_aggressive',    a:'asm_unit_econ',  w:1.0},
  {s:'scn_aggressive',    a:'asm_holding',    w:1.0}, {s:'scn_aggressive',    a:'asm_demand',     w:1.0},
  {s:'scn_hybrid',        a:'asm_forecast',   w:0.5}, {s:'scn_hybrid',        a:'asm_throughput', w:0.5},
  {s:'scn_hybrid',        a:'asm_liquidity',  w:0.5}, {s:'scn_hybrid',        a:'asm_unit_econ',  w:0.7},
  {s:'scn_hybrid',        a:'asm_holding',    w:0.5}, {s:'scn_hybrid',        a:'asm_demand',     w:1.0},
  {s:'scn_capital_light', a:'asm_forecast',   w:0.1}, {s:'scn_capital_light', a:'asm_throughput', w:0.1},
  {s:'scn_capital_light', a:'asm_liquidity',  w:0.1}, {s:'scn_capital_light', a:'asm_unit_econ',  w:0.3},
  {s:'scn_capital_light', a:'asm_holding',    w:0.1}, {s:'scn_capital_light', a:'asm_demand',     w:1.0}
] AS row
MATCH (s:Scenario {id: row.s}), (a:Assumption {id: row.a})
MERGE (s)-[r:REQUIRES]->(a) SET r.weight = row.w;


// --- 7. Evidence to assumption, with polarity and strength -------------------
UNWIND [
  {e:'ev_mgmt_conf',  a:'asm_demand',     strength:0.5},
  {e:'ev_cash',       a:'asm_liquidity',  strength:0.8},
  {e:'ev_homes_sold', a:'asm_demand',     strength:0.7}
] AS row
MATCH (e:Evidence {id: row.e}), (a:Assumption {id: row.a})
MERGE (e)-[r:SUPPORTS]->(a) SET r.strength = row.strength;

UNWIND [
  {e:'ev_10k2019',    a:'asm_holding',    strength:0.2},
  {e:'ev_10k2020',    a:'asm_holding',    strength:0.2},
  {e:'ev_homes_loss', a:'asm_unit_econ',  strength:0.7},
  {e:'ev_inventory',  a:'asm_throughput', strength:0.9},
  {e:'ev_inventory',  a:'asm_liquidity',  strength:0.5},
  {e:'ev_holding',    a:'asm_holding',    strength:0.8}
] AS row
MATCH (e:Evidence {id: row.e}), (a:Assumption {id: row.a})
MERGE (e)-[r:CONTRADICTS]->(a) SET r.strength = row.strength;


// --- 8. If this assumption fails, this is the consequence ---------------------
UNWIND [
  {a:'asm_throughput', x:'exp_inventory'}, {a:'asm_throughput', x:'exp_liquidity'},
  {a:'asm_holding',    x:'exp_inventory'}, {a:'asm_forecast',   x:'exp_writedown'},
  {a:'asm_unit_econ',  x:'exp_writedown'}, {a:'asm_liquidity',  x:'exp_liquidity'},
  {a:'asm_demand',     x:'exp_growth'}
] AS row
MATCH (a:Assumption {id: row.a}), (x:Exposure {id: row.x})
MERGE (a)-[:IF_FALSE_CAUSES]->(x);


// --- 9. How much each scenario amplifies each exposure ------------------------
// Principal ownership multiplies inventory exposure. Referral barely touches it.
UNWIND [
  {s:'scn_aggressive',    x:'exp_inventory', m:2.0}, {s:'scn_aggressive',    x:'exp_writedown', m:2.0},
  {s:'scn_aggressive',    x:'exp_liquidity', m:2.0}, {s:'scn_aggressive',    x:'exp_growth',    m:1.0},
  {s:'scn_hybrid',        x:'exp_inventory', m:1.0}, {s:'scn_hybrid',        x:'exp_writedown', m:1.0},
  {s:'scn_hybrid',        x:'exp_liquidity', m:1.0}, {s:'scn_hybrid',        x:'exp_growth',    m:1.0},
  {s:'scn_capital_light', x:'exp_inventory', m:0.1}, {s:'scn_capital_light', x:'exp_writedown', m:0.1},
  {s:'scn_capital_light', x:'exp_liquidity', m:0.1}, {s:'scn_capital_light', x:'exp_growth',    m:1.0}
] AS row
MATCH (s:Scenario {id: row.s}), (x:Exposure {id: row.x})
MERGE (s)-[r:CARRIES]->(x) SET r.multiplier = row.m;


// --- 10. Tripwires — frozen BEFORE, evaluated AFTER ---------------------------
// frozen_on is 2021-02-10. There is deliberately NO edge from Evidence to
// Tripwire: whether it fires is computed at query time. Pre-storing the answer
// would be hindsight.
UNWIND [
  {id:'tw_inventory', a:'asm_throughput', metric:'homes_inventory_usd', threshold:1000000000.0,
   condition:'Homes inventory exceeds $1bn', action:'REASSESS / PAUSE-SCALE'},
  {id:'tw_holding',   a:'asm_holding',    metric:'holding_costs_usd',   threshold:4000000.0,
   condition:'Quarterly holding costs exceed $4m', action:'INVESTIGATE / SLOW ACQUISITION'}
] AS row
MERGE (t:Tripwire {id: row.id})
SET t.metric = row.metric, t.threshold = row.threshold, t.direction = 'above',
    t.condition = row.condition, t.action = row.action, t.frozen_on = date('2021-02-10')
WITH t, row
MATCH (a:Assumption {id: row.a})
MERGE (t)-[:WATCHES]->(a);


// --- 11. SANITY CHECK — must return the expected totals -----------------------
// Expected: 24 nodes, 51 relationships.
// StrategicBet 1 | Scenario 3 | Assumption 6 | Evidence 8 | Exposure 4 | Tripwire 2
MATCH (n) WITH count(n) AS nodes
MATCH ()-[r]->() WITH nodes, count(r) AS rels
MATCH (e:Evidence) WITH nodes, rels, count(e) AS evidence
RETURN nodes, rels, evidence,
       CASE WHEN nodes = 24 AND rels = 51 THEN 'SEED OK'
            ELSE 'CHECK — expected 24 nodes / 51 rels' END AS status;
