// =============================================================================
// 01b_additions.cypher — RUN AFTER 01_seed_graph.cypher
//
// Two additions to the starter kit. Both are non-destructive (MERGE) and both
// use the kit's existing conventions: project scoping, BEARS_ON {direction,
// weight, reason}, DEPENDS_ON {criticality}.
//
// WHY THESE TWO:
//
// 1. E_FY2020_10K — the FY2020 Form 10-K, public_from 2021-02-12.
//    The survival guide flags this as the correction found while preparing the
//    kit: the 10-K was filed TWO DAYS AFTER the 10 February checkpoint, so it
//    is ineligible at T0. The kit describes this but has no node for it. With
//    the node present you can SHOW the boundary rejecting a document rather
//    than just asserting that it would.
//
// 2. A_DEMAND — an assumption that does NOT deteriorate.
//    Every assumption in the base kit gets worse. That makes the graph look
//    like it can only say one thing. Zillow's demand side was genuinely fine —
//    people wanted instant offers; that was never the failure. Adding it costs
//    nothing (its evidence balance stays positive, so it contributes ZERO risk
//    signal and does not change any scenario score) and it buys the single
//    most useful demo line: "the graph is not just pessimistic — look, this
//    one holds."
//    No new evidence is invented: both edges attach to evidence already in the
//    kit, whose claim text already mentions demand.
// =============================================================================


// --- 1. The FY2020 10-K: present in the graph, ineligible at T0 --------------
MERGE (e:Evidence {id:'E_FY2020_10K'})
SET e.project = 'zillow_strategy_time_machine',
    e.public_from = date('2021-02-12'),
    e.title = 'FY2020 Form 10-K filed',
    e.claim = 'Annual report for FY2020; inventory, holding-cost and liquidation risk factors for principal iBuying restated.',
    e.source_url = 'https://www.sec.gov/edgar/search/#/entityName=Zillow%20Group&forms=10-K',
    e.note = 'Filed 2021-02-12. TWO DAYS after the 10 February checkpoint. Ineligible at T0 by two days.';

MATCH (e:Evidence {id:'E_FY2020_10K'}), (a:Assumption {id:'A_LIQUIDITY'})
MERGE (e)-[:BEARS_ON {direction:-1, weight:1,
  reason:'Restates structural liquidation risk. Note: not eligible at the 2021-02-10 cutoff.'}]->(a);


// --- 2. An assumption that holds ---------------------------------------------
MERGE (a:Assumption {id:'A_DEMAND'})
SET a.project = 'zillow_strategy_time_machine',
    a.name = 'Consumer demand for instant cash offers exists at the required scale',
    a.category = 'demand';

MERGE (x:Exposure {id:'X_GROWTH'})
SET x.project = 'zillow_strategy_time_machine',
    x.name = 'Segment fails to reach scale',
    x.type = 'growth';

MATCH (a:Assumption {id:'A_DEMAND'}), (x:Exposure {id:'X_GROWTH'})
MERGE (a)-[:FAILURE_EXPOSES {severity:2}]->(x);

// Every form of the bet needs sellers. The capital-light model needs them most:
// demand IS the business there, so its criticality is high even though its
// inventory-side criticalities are low. Criticality is about dependence, not
// about how well things went.
MATCH (a:Assumption {id:'A_DEMAND'})
UNWIND [{s:'S_AGGRESSIVE', c:3}, {s:'S_HYBRID', c:2}, {s:'S_CAPITAL_LIGHT', c:3}] AS row
MATCH (s:Scenario {id: row.s})
MERGE (s)-[:DEPENDS_ON {criticality: row.c}]->(a);

// Both edges attach to evidence ALREADY in the kit. Nothing invented.
MATCH (e:Evidence {id:'E_T0_MANAGEMENT_CONFIDENCE'}), (a:Assumption {id:'A_DEMAND'})
MERGE (e)-[:BEARS_ON {direction:1, weight:2,
  reason:'Management cites strong demand entering 2021.'}]->(a);

MATCH (e:Evidence {id:'E_Q2_SALES'}), (a:Assumption {id:'A_DEMAND'})
MERGE (e)-[:BEARS_ON {direction:1, weight:2,
  reason:'2,086 homes sold and $772m revenue: demand was realised, not hypothetical.'}]->(a);


// --- 3. Check ----------------------------------------------------------------
MATCH (n {project:'zillow_strategy_time_machine'})
OPTIONAL MATCH (n)-[r]->()
RETURN count(DISTINCT n) AS project_nodes, count(DISTINCT r) AS project_relationships;


// --- 4. The two-days-matter query — worth its own demo beat ------------------
// At cutoff 2021-02-10 this returns the 10-K as NOT ELIGIBLE.
// SAY: a summariser handed "Zillow's annual report and the Q4 release" blends
//      them without noticing. The graph refuses, because the filing date is a
//      property of the evidence and the query filters on it.
MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine'
RETURN e.public_from AS public_from, e.title AS evidence,
       CASE WHEN e.public_from <= date('2021-02-10') THEN 'ELIGIBLE'
            ELSE 'NOT ELIGIBLE AT T0' END AS at_10_feb,
       CASE WHEN e.public_from <= date('2021-08-05') THEN 'ELIGIBLE'
            ELSE 'not eligible' END AS at_05_aug
ORDER BY public_from;
