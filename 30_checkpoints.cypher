// =============================================================================
// 30_checkpoints.cypher — CHECKPOINTS BECOME DATA, NOT QUERY TEXT
// Any bet declares its own checkpoints. Queries read them from the graph.
// =============================================================================
CREATE CONSTRAINT checkpoint_id IF NOT EXISTS
FOR (n:Checkpoint) REQUIRE n.id IS UNIQUE;

MATCH (b:StrategicBet {id:'BET_SCALE'})
UNWIND [
  {id:'CP_T0', on:'2021-02-10', label:'Primary checkpoint - Q4/FY2020 disclosures'},
  {id:'CP_Q2', on:'2021-08-05', label:'Q2 2021 acceleration checkpoint'}
] AS row
MERGE (c:Checkpoint {id: row.id})
SET c.project = 'zillow_strategy_time_machine',
    c.on = date(row.on), c.label = row.label
MERGE (b)-[:HAS_CHECKPOINT]->(c);

MATCH (b:StrategicBet)-[:HAS_CHECKPOINT]->(c:Checkpoint)
RETURN b.name AS bet, c.on AS checkpoint, c.label AS label ORDER BY c.on;
