// =============================================================================
// 37_simulate_run.cypher — RUN THIS. No parameters, both checkpoints at once.
// Replaces the broken risk-only scoring with the exposure ratio.
// =============================================================================

// --- A · how exposed is each strategy, at each checkpoint? -------------------
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cut
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= cut AND (e.public_until IS NULL OR e.public_until > cut)
WITH cut, s, a, d, sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH cut, s, sum(d.criticality) AS total,
     sum(CASE WHEN bal > 0 THEN 0 ELSE d.criticality END) AS unproven
WITH s.name AS strategy,
     max(CASE WHEN cut = date('2021-02-10') THEN toInteger(round(100.0*unproven/total)) END) AS feb,
     max(CASE WHEN cut = date('2021-08-05') THEN toInteger(round(100.0*unproven/total)) END) AS aug
RETURN strategy,
       toString(feb) + '%' AS pct_unproven_10_feb,
       toString(aug) + '%' AS pct_unproven_5_aug
ORDER BY aug;
// expect  Capital-light 20% -> 40% | Hybrid 67% -> 78% | Aggressive 71% -> 82%


// --- B · which single belief actually decides the choice? --------------------
MATCH (flip:Assumption) WHERE flip.project = 'zillow_strategy_time_machine'
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= date('2021-02-10')
    AND (e.public_until IS NULL OR e.public_until > date('2021-02-10'))
WITH flip, s, a, d, sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH flip, s, sum(d.criticality) AS total,
     sum(CASE WHEN a.id = flip.id OR bal <= 0 THEN d.criticality ELSE 0 END) AS unproven
WITH flip, collect({s:s.name, pct:100.0*unproven/total}) AS rows
WITH flip, reduce(b = rows[0], x IN rows | CASE WHEN x.pct < b.pct THEN x ELSE b END) AS best
RETURN left(flip.name, 52) AS if_this_turned_out_false,
       best.s AS least_exposed_strategy,
       toInteger(round(best.pct)) AS its_pct_unproven,
       CASE WHEN best.s = 'Capital-light marketplace' THEN '' ELSE '<<< CHANGES THE CHOICE' END AS note
ORDER BY note DESC, if_this_turned_out_false;
// Only ONE assumption should change the answer. That is where diligence goes.
