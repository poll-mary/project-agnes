// Every strategy must be judged on ALL SIX of Agnes's categories.
// Capital-light previously had no link to forecasting, operations or liquidity,
// which claimed it had ZERO exposure there. It has LESS, not none.
MATCH (s:Scenario {id:'S_CAPITAL_LIGHT'})
UNWIND [{a:'A_FORECAST',c:1},{a:'A_THROUGHPUT',c:1},{a:'A_LIQUIDITY',c:1}] AS row
MATCH (a:Assumption {id: row.a})
MERGE (s)-[r:DEPENDS_ON]->(a) SET r.criticality = row.c;

// hybrid carries real inventory risk too - it was under-weighted
MATCH (s:Scenario {id:'S_HYBRID'})-[r:DEPENDS_ON]->(a:Assumption)
WHERE a.id IN ['A_THROUGHPUT','A_LIQUIDITY','A_FINANCING'] SET r.criticality = 2;
MATCH (s:Scenario {id:'S_HYBRID'})-[r:DEPENDS_ON]->(a:Assumption {id:'A_DEMAND'})
SET r.criticality = 3;
MATCH (s:Scenario {id:'S_CAPITAL_LIGHT'})-[r:DEPENDS_ON]->(a:Assumption {id:'A_UNIT'})
SET r.criticality = 2;

// check: every strategy now answers all six
MATCH (s:Scenario)-[:DEPENDS_ON]->(a:Assumption)
RETURN s.name AS strategy, count(a) AS categories_scored_on
ORDER BY strategy;
