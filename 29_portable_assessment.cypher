// =============================================================================
// 29_portable_assessment.cypher — NO HARDCODED IDS, NO HARDCODED DATES
//
// Checkpoints come from the graph, not the query text. Scenarios and
// assumptions are iterated, never named. This query runs against ANY bet
// loaded into Agnes without editing a character.
//
// Requires checkpoints to exist. Run 30_checkpoints.cypher first.
// =============================================================================

MATCH (b:StrategicBet)-[:HAS_CHECKPOINT]->(c:Checkpoint)
WITH b, c ORDER BY c.on
WITH b, collect(c.on) AS checkpoints
UNWIND checkpoints AS cut

MATCH (b)-[:CONSIDERS]->(:Scenario)-[:DEPENDS_ON]->(a:Assumption)
WHERE a.declared_on IS NULL OR a.declared_on <= cut
WITH b, cut, a

OPTIONAL MATCH (ei:Evidence {origin:'INTERNAL'})-[ri:BEARS_ON]->(a)
  WHERE ei.public_from <= cut AND (ei.public_until IS NULL OR ei.public_until > cut)
WITH b, cut, a, count(DISTINCT ei) AS i_n,
     sum(CASE WHEN ei IS NULL THEN 0 ELSE ri.direction * ri.weight END) AS i_bal

OPTIONAL MATCH (ex:Evidence {origin:'EXTERNAL'})-[rx:BEARS_ON]->(a)
  WHERE ex.public_from <= cut AND (ex.public_until IS NULL OR ex.public_until > cut)
WITH b, cut, a, i_n, i_bal, count(DISTINCT ex) AS x_n,
     sum(CASE WHEN ex IS NULL THEN 0 ELSE rx.direction * rx.weight END) AS x_bal

RETURN b.name AS bet, cut AS as_at,
       left(a.name, 46) AS must_be_true,
       CASE WHEN i_n = 0 THEN 'SILENT' ELSE toString(i_bal) END AS from_the_company,
       CASE WHEN x_n = 0 THEN 'silent' ELSE toString(x_bal) END AS from_the_world,
       CASE WHEN i_n + x_n = 0 THEN 'NOT EVIDENCED'
            WHEN i_bal + x_bal > 0 THEN 'supported'
            WHEN i_bal + x_bal = 0 THEN 'mixed'
            ELSE 'CHALLENGED' END AS state
ORDER BY bet, as_at, must_be_true;
