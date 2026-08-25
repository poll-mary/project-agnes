// =============================================================================
// 38_sensitivity.cypher — SIMULATE, CORRECTED AGAIN
//
// The previous version asked "does this change which strategy wins?" and the
// answer was always no. Capital-light is ALWAYS least exposed - it owns
// nothing, so that is true by construction and not a finding at all.
//
// The right question is the SWING: if this belief turned out false, how much
// would each strategy's exposure move? A belief that moves nothing is already
// priced in. A belief with a big swing is still load-bearing, and that is
// where diligence belongs.
// =============================================================================

MATCH (flip:Assumption) WHERE flip.project = 'zillow_strategy_time_machine'
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= date('2021-02-10')
    AND (e.public_until IS NULL OR e.public_until > date('2021-02-10'))
WITH flip, s, a, d,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH flip, s, sum(d.criticality) AS total,
     sum(CASE WHEN bal <= 0 THEN d.criticality ELSE 0 END) AS base_unproven,
     sum(CASE WHEN a.id = flip.id OR bal <= 0 THEN d.criticality ELSE 0 END) AS flip_unproven
WITH flip,
     collect({s:s.name,
              base: toInteger(round(100.0*base_unproven/total)),
              flip: toInteger(round(100.0*flip_unproven/total))}) AS rows
WITH flip, rows,
     reduce(m = 0, x IN rows | CASE WHEN x.flip - x.base > m THEN x.flip - x.base ELSE m END) AS swing
RETURN left(flip.name, 46) AS if_this_turned_out_false,
       [x IN rows | x.s + ': ' + toString(x.base) + '% -> ' + toString(x.flip) + '%'] AS exposure,
       swing AS worst_swing,
       CASE WHEN swing = 0 THEN 'already assumed broken - no new information'
            WHEN swing >= 40 THEN 'STILL LOAD-BEARING - find out about this'
            ELSE 'partly load-bearing' END AS verdict
ORDER BY swing DESC;

// At 10 Feb 2021:
//   consumer demand  +60  <- would damage even the safe option
//   financing        +20
//   the other four   +0   <- already unproven, so failing changes nothing
