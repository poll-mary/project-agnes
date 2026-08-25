// ZILLOW STRATEGY TIME MACHINE — MINIMUM HACKATHON GRAPH
// Safe to rerun: MERGE uses stable IDs. Every node is scoped to this project.

// OPTIONAL CLEANUP — run only if you want to delete an earlier copy of THIS demo.
// MATCH (n {project: 'zillow_strategy_time_machine'}) DETACH DELETE n;

// Constraints
CREATE CONSTRAINT strategic_bet_id IF NOT EXISTS
FOR (n:StrategicBet) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT scenario_id IF NOT EXISTS
FOR (n:Scenario) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT assumption_id IF NOT EXISTS
FOR (n:Assumption) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT evidence_id IF NOT EXISTS
FOR (n:Evidence) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT exposure_id IF NOT EXISTS
FOR (n:Exposure) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT tripwire_id IF NOT EXISTS
FOR (n:Tripwire) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT observation_id IF NOT EXISTS
FOR (n:MetricObservation) REQUIRE n.id IS UNIQUE;

// Strategic bet
MERGE (b:StrategicBet {id: 'BET_SCALE'})
SET b.project = 'zillow_strategy_time_machine',
    b.name = 'Scale Zillow Offers',
    b.question = 'Should Zillow aggressively scale principal iBuying?',
    b.primary_cutoff = date('2021-02-10');

// Alternative scenarios
UNWIND [
  {id:'S_AGGRESSIVE', name:'Aggressive principal iBuying', inventory_intensity:3},
  {id:'S_HYBRID', name:'Hybrid / partner iBuying', inventory_intensity:2},
  {id:'S_CAPITAL_LIGHT', name:'Capital-light marketplace', inventory_intensity:0}
] AS row
MERGE (s:Scenario {id: row.id})
SET s.project = 'zillow_strategy_time_machine',
    s.name = row.name,
    s.inventory_intensity = row.inventory_intensity;

MATCH (b:StrategicBet {id:'BET_SCALE'}), (s:Scenario)
WHERE s.project = 'zillow_strategy_time_machine'
MERGE (b)-[:CONSIDERS]->(s);

// Decision-critical assumptions
UNWIND [
  {id:'A_FORECAST', name:'Forward resale prices can be forecast within tolerable error', category:'forecasting'},
  {id:'A_UNIT', name:'Unit economics remain defensible as volume scales', category:'economics'},
  {id:'A_THROUGHPUT', name:'Renovation and resale throughput can keep pace with acquisitions', category:'operations'},
  {id:'A_LIQUIDITY', name:'Inventory can be liquidated quickly enough under adverse moves', category:'liquidity'},
  {id:'A_FINANCING', name:'Working-capital and financing needs remain acceptable at scale', category:'capital'}
] AS row
MERGE (a:Assumption {id: row.id})
SET a.project = 'zillow_strategy_time_machine',
    a.name = row.name,
    a.category = row.category;

// Exposures
UNWIND [
  {id:'X_INVENTORY', name:'Inventory value at risk', type:'balance_sheet'},
  {id:'X_HOLDING', name:'Holding costs and value depreciation', type:'cost'},
  {id:'X_MARGIN', name:'Homes segment loss / margin compression', type:'profitability'},
  {id:'X_CAPITAL', name:'Capital and financing concentration', type:'capital'}
] AS row
MERGE (x:Exposure {id: row.id})
SET x.project = 'zillow_strategy_time_machine',
    x.name = row.name,
    x.type = row.type;

// Scenario dependency structure. Criticality: 1 low, 2 medium, 3 high.
MATCH (s:Scenario {id:'S_AGGRESSIVE'}),
      (af:Assumption {id:'A_FORECAST'}),
      (au:Assumption {id:'A_UNIT'}),
      (at:Assumption {id:'A_THROUGHPUT'}),
      (al:Assumption {id:'A_LIQUIDITY'}),
      (ac:Assumption {id:'A_FINANCING'})
MERGE (s)-[:DEPENDS_ON {criticality:3}]->(af)
MERGE (s)-[:DEPENDS_ON {criticality:3}]->(au)
MERGE (s)-[:DEPENDS_ON {criticality:3}]->(at)
MERGE (s)-[:DEPENDS_ON {criticality:3}]->(al)
MERGE (s)-[:DEPENDS_ON {criticality:2}]->(ac);

MATCH (s:Scenario {id:'S_HYBRID'}),
      (af:Assumption {id:'A_FORECAST'}),
      (au:Assumption {id:'A_UNIT'}),
      (at:Assumption {id:'A_THROUGHPUT'}),
      (al:Assumption {id:'A_LIQUIDITY'}),
      (ac:Assumption {id:'A_FINANCING'})
MERGE (s)-[:DEPENDS_ON {criticality:2}]->(af)
MERGE (s)-[:DEPENDS_ON {criticality:2}]->(au)
MERGE (s)-[:DEPENDS_ON {criticality:1}]->(at)
MERGE (s)-[:DEPENDS_ON {criticality:1}]->(al)
MERGE (s)-[:DEPENDS_ON {criticality:1}]->(ac);

MATCH (s:Scenario {id:'S_CAPITAL_LIGHT'}),
      (au:Assumption {id:'A_UNIT'}),
      (ac:Assumption {id:'A_FINANCING'})
MERGE (s)-[:DEPENDS_ON {criticality:1}]->(au)
MERGE (s)-[:DEPENDS_ON {criticality:1}]->(ac);

// Failure paths from assumptions to exposures
MATCH (a:Assumption {id:'A_FORECAST'}), (x:Exposure {id:'X_INVENTORY'})
MERGE (a)-[:FAILURE_EXPOSES {severity:3}]->(x);
MATCH (a:Assumption {id:'A_FORECAST'}), (x:Exposure {id:'X_MARGIN'})
MERGE (a)-[:FAILURE_EXPOSES {severity:3}]->(x);
MATCH (a:Assumption {id:'A_UNIT'}), (x:Exposure {id:'X_MARGIN'})
MERGE (a)-[:FAILURE_EXPOSES {severity:3}]->(x);
MATCH (a:Assumption {id:'A_THROUGHPUT'}), (x:Exposure {id:'X_INVENTORY'})
MERGE (a)-[:FAILURE_EXPOSES {severity:3}]->(x);
MATCH (a:Assumption {id:'A_THROUGHPUT'}), (x:Exposure {id:'X_HOLDING'})
MERGE (a)-[:FAILURE_EXPOSES {severity:3}]->(x);
MATCH (a:Assumption {id:'A_LIQUIDITY'}), (x:Exposure {id:'X_HOLDING'})
MERGE (a)-[:FAILURE_EXPOSES {severity:3}]->(x);
MATCH (a:Assumption {id:'A_FINANCING'}), (x:Exposure {id:'X_CAPITAL'})
MERGE (a)-[:FAILURE_EXPOSES {severity:2}]->(x);

// Scenario exposure intensity
MATCH (s:Scenario {id:'S_AGGRESSIVE'}), (xi:Exposure {id:'X_INVENTORY'}),
      (xh:Exposure {id:'X_HOLDING'}), (xc:Exposure {id:'X_CAPITAL'})
MERGE (s)-[:CREATES_EXPOSURE {intensity:3}]->(xi)
MERGE (s)-[:CREATES_EXPOSURE {intensity:3}]->(xh)
MERGE (s)-[:CREATES_EXPOSURE {intensity:3}]->(xc);

MATCH (s:Scenario {id:'S_HYBRID'}), (xi:Exposure {id:'X_INVENTORY'}),
      (xh:Exposure {id:'X_HOLDING'}), (xc:Exposure {id:'X_CAPITAL'})
MERGE (s)-[:CREATES_EXPOSURE {intensity:1}]->(xi)
MERGE (s)-[:CREATES_EXPOSURE {intensity:1}]->(xh)
MERGE (s)-[:CREATES_EXPOSURE {intensity:1}]->(xc);

// Point-in-time evidence. direction: +1 supports, -1 contradicts. weight: 1–3.
UNWIND [
  {
    id:'E_2019_INVENTORY_RISK',
    public_from:'2020-02-19',
    title:'2019 Form 10-K: inventory and holding risk',
    claim:'Principal iBuying is cash- and inventory-intensive; slower sales can increase holding costs and pressure profitability.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764020000015/z-20191231.htm'
  },
  {
    id:'E_T0_MANAGEMENT_CONFIDENCE',
    public_from:'2021-02-10',
    title:'Q4/FY2020 earnings release: management confidence',
    claim:'Management said Zillow was investing aggressively and was positioned to capitalize on strong demand in 2021.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000007/q42020991.htm'
  },
  {
    id:'E_T0_HOMES_LOSS',
    public_from:'2021-02-10',
    title:'Q4/FY2020 earnings release: Homes segment loss',
    claim:'Homes segment loss before income taxes was $320.254 million for full-year 2020 and $66.621 million in Q4.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000007/q42020991.htm'
  },
  {
    id:'E_T0_CASH',
    public_from:'2021-02-10',
    title:'Q4/FY2020 earnings release: liquidity',
    claim:'Zillow exited 2020 with $3.9 billion in cash and investments.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000007/q42020991.htm'
  },
  {
    id:'E_Q2_SALES',
    public_from:'2021-08-05',
    title:'Q2 2021 Form 10-Q: homes sold',
    claim:'Zillow Offers sold 2,086 homes in Q2 2021 and generated $772.0 million of revenue.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000055/z-20210630.htm'
  },
  {
    id:'E_Q2_INVENTORY',
    public_from:'2021-08-05',
    title:'Q2 2021 Form 10-Q: inventory expansion',
    claim:'Inventory increased from $491.293 million at 31 December 2020 to $1.169601 billion at 30 June 2021, approximately 138% growth.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000055/z-20210630.htm'
  },
  {
    id:'E_Q2_HOLDING_COST',
    public_from:'2021-08-05',
    title:'Q2 2021 Form 10-Q: holding costs',
    claim:'Homes segment holding costs were $5.3 million in Q2 2021 versus $2.6 million in Q2 2020.',
    source_url:'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000055/z-20210630.htm'
  }
] AS row
MERGE (e:Evidence {id: row.id})
SET e.project = 'zillow_strategy_time_machine',
    e.public_from = date(row.public_from),
    e.title = row.title,
    e.claim = row.claim,
    e.source_url = row.source_url;

// Evidence relationships
MATCH (e:Evidence {id:'E_2019_INVENTORY_RISK'}), (a:Assumption {id:'A_LIQUIDITY'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:2, reason:'Pre-existing disclosed structural risk'}]->(a);
MATCH (e:Evidence {id:'E_2019_INVENTORY_RISK'}), (a:Assumption {id:'A_THROUGHPUT'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:1, reason:'Slow resale creates inventory and holding exposure'}]->(a);
MATCH (e:Evidence {id:'E_T0_MANAGEMENT_CONFIDENCE'}), (a:Assumption {id:'A_UNIT'})
MERGE (e)-[:BEARS_ON {direction:1, weight:1, reason:'Positive strategic confidence, but not direct unit-economics proof'}]->(a);
MATCH (e:Evidence {id:'E_T0_HOMES_LOSS'}), (a:Assumption {id:'A_UNIT'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:3, reason:'Material loss challenges scale economics'}]->(a);
MATCH (e:Evidence {id:'E_T0_CASH'}), (a:Assumption {id:'A_FINANCING'})
MERGE (e)-[:BEARS_ON {direction:1, weight:2, reason:'Substantial corporate liquidity supports near-term funding capacity'}]->(a);
MATCH (e:Evidence {id:'E_Q2_SALES'}), (a:Assumption {id:'A_THROUGHPUT'})
MERGE (e)-[:BEARS_ON {direction:1, weight:1, reason:'Sales volume demonstrates some resale throughput'}]->(a);
MATCH (e:Evidence {id:'E_Q2_INVENTORY'}), (a:Assumption {id:'A_THROUGHPUT'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:3, reason:'Inventory grew much faster than evidence of downstream capacity'}]->(a);
MATCH (e:Evidence {id:'E_Q2_INVENTORY'}), (a:Assumption {id:'A_LIQUIDITY'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:3, reason:'Larger principal inventory magnifies liquidation exposure'}]->(a);
MATCH (e:Evidence {id:'E_Q2_INVENTORY'}), (a:Assumption {id:'A_FINANCING'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:2, reason:'Inventory expansion increases capital concentration'}]->(a);
MATCH (e:Evidence {id:'E_Q2_HOLDING_COST'}), (a:Assumption {id:'A_LIQUIDITY'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:2, reason:'Rising holding costs increase the cost of slow liquidation'}]->(a);

// Frozen prototype tripwire. This is a demo governance rule, not a validated universal threshold.
MERGE (t:Tripwire {id:'T_INVENTORY_1B'})
SET t.project = 'zillow_strategy_time_machine',
    t.name = 'Inventory concentration guardrail',
    t.metric = 'inventory_usd_m',
    t.threshold_value = 1000.0,
    t.operator = '>',
    t.action = 'REASSESS / PAUSE-SCALE',
    t.frozen_at = date('2021-02-10'),
    t.note = 'Prototype threshold for the hackathon; requires expert validation in the real product.';

MATCH (t:Tripwire {id:'T_INVENTORY_1B'}), (x:Exposure {id:'X_INVENTORY'})
MERGE (t)-[:MONITORS]->(x);

MERGE (o:MetricObservation {id:'O_Q2_INVENTORY'})
SET o.project = 'zillow_strategy_time_machine',
    o.metric = 'inventory_usd_m',
    o.value = 1169.601,
    o.unit = 'USD millions',
    o.valid_at = date('2021-06-30'),
    o.public_from = date('2021-08-05'),
    o.source_url = 'https://www.sec.gov/Archives/edgar/data/1617640/000161764021000055/z-20210630.htm';

MATCH (o:MetricObservation {id:'O_Q2_INVENTORY'}), (x:Exposure {id:'X_INVENTORY'})
MERGE (o)-[:MEASURES]->(x);

// Final sanity check
MATCH (n {project:'zillow_strategy_time_machine'})
OPTIONAL MATCH (n)-[r]->()
RETURN count(DISTINCT n) AS project_nodes, count(DISTINCT r) AS project_relationships;

