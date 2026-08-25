// =============================================================================
// 36_simulate_fixed.cypher — SIMULATE, REDESIGNED
//
// THE OLD MODEL WAS BROKEN. It summed risk in absolute terms, so the strategy
// with the fewest dependencies won unconditionally, whatever the evidence said.
// Our own sensitivity test caught it: flipping any assumption to total failure
// never changed the answer.
//
// THE FIX is not to invent upside numbers. It is to score a RATIO:
//     what fraction of what this strategy needs is currently unproven?
// Normalising by each strategy's own total dependency weight removes the
// dependency-count artefact, so evidence decides the ranking.
// =============================================================================

// --- 1. Exposure ratio per strategy, at a checkpoint -------------------------
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= $cut AND (e.public_until IS NULL OR e.public_until > $cut)
WITH s, a, d, sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH s, sum(d.criticality) AS total,
     sum(CASE WHEN bal > 0 THEN 0 ELSE d.criticality END) AS unproven
RETURN s.name AS strategy,
       unproven AS unproven_weight,
       total AS total_weight,
       toInteger(round(100.0 * unproven / total)) AS pct_of_needs_unproven
ORDER BY pct_of_needs_unproven;

// Expected at 2021-02-10 : Capital-light 20 | Hybrid 67 | Aggressive 71
// Expected at 2021-08-05 : Capital-light 40 | Hybrid 78 | Aggressive 82


// --- 2. INVERSE: which single assumption decides the choice? -----------------
// Flip each assumption to failed in turn and see whether the ranking moves.
// Anything that does not move the ranking is not worth diligence spend.
MATCH (flip:Assumption) WHERE flip.project = 'zillow_strategy_time_machine'
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= $cut AND (e.public_until IS NULL OR e.public_until > $cut)
WITH flip, s, a, d, sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH flip, s, sum(d.criticality) AS total,
     sum(CASE WHEN a.id = flip.id OR bal <= 0 THEN d.criticality ELSE 0 END) AS unproven
WITH flip, collect({s: s.name, pct: 100.0 * unproven / total}) AS rows
WITH flip, rows,
     reduce(best = rows[0], x IN rows | CASE WHEN x.pct < best.pct THEN x ELSE best END) AS winner
RETURN flip.name AS if_this_turned_out_false,
       winner.s AS least_exposed_strategy,
       toInteger(round(winner.pct)) AS its_pct_unproven
ORDER BY if_this_turned_out_false;

// At 2021-02-10 the least-exposed strategy is Capital-light in every case
// EXCEPT consumer demand — which is the only assumption that changes the
// answer. That is where diligence money should go.
