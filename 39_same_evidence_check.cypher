// Does every strategy see exactly the same evidence? Prove it.
MATCH (s:Scenario)-[:DEPENDS_ON]->(a:Assumption)<-[:BEARS_ON]-(e:Evidence)
  WHERE e.public_from <= date('2021-08-05')
    AND (e.public_until IS NULL OR e.public_until > date('2021-08-05'))
WITH s, collect(DISTINCT e.id) AS seen
RETURN s.name AS strategy,
       size(seen) AS evidence_items_reaching_it,
       size([x IN seen WHERE x STARTS WITH 'E_']) AS from_zillow,
       size([x IN seen WHERE x STARTS WITH 'X_']) AS from_the_world
ORDER BY evidence_items_reaching_it DESC;
// Capital-light sees FEWER items - not because any was withheld, but because it
// depends on fewer conditions. Same pool, different surface area.
