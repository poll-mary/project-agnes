// =============================================================================
// 32_confidence.cypher — AGNES QUALIFIES HER OWN CONCLUSIONS
//
// Agnes knows some indicators are unloaded. Until now that sat in a separate
// coverage report, so every conclusion read as equally well-founded.
//
// Now each assumption's state carries how much Agnes actually knows about it:
//   - how many sources bear on it
//   - whether they are internal, external, or both
//   - how many indicators that SHOULD inform it have no data at all
//
// A conclusion drawn from one unloaded panel is not the same as one drawn from
// six sources, and Agnes should never present them identically.
// =============================================================================

MATCH (a:Assumption) WHERE a.project = 'zillow_strategy_time_machine'

OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= date('2021-08-05')
    AND (e.public_until IS NULL OR e.public_until > date('2021-08-05'))
WITH a, count(DISTINCT e) AS sources,
     count(DISTINCT e.origin) AS origin_types,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS balance,
     max(CASE WHEN e.source_authority IS NULL THEN 0 ELSE e.source_authority END) AS best_authority

// indicators that are SUPPOSED to inform this assumption but carry no data
OPTIONAL MATCH (i:WorldIndicator)-[:INFORMS]->(a)
WITH a, sources, origin_types, balance, best_authority,
     count(i) AS indicators_declared,
     sum(CASE WHEN i.status = 'NOT_LOADED' THEN 1 ELSE 0 END) AS indicators_missing

RETURN left(a.name, 44) AS must_be_true,
       CASE WHEN sources = 0 THEN 'NOT EVIDENCED'
            WHEN balance > 0 THEN 'supported'
            WHEN balance = 0 THEN 'mixed'
            ELSE 'CHALLENGED' END AS state,
       balance,
       sources AS sources_used,
       CASE WHEN origin_types = 2 THEN 'company + world'
            WHEN origin_types = 1 THEN 'one side only'
            ELSE 'none' END AS breadth,
       best_authority AS strongest_source,
       indicators_missing AS blind_spots,
       CASE
         WHEN sources = 0 THEN 'NO BASIS - Agnes knows nothing here'
         WHEN indicators_missing > 0 AND origin_types < 2
           THEN 'LOW - one side only, and ' + toString(indicators_missing) + ' indicator(s) unloaded'
         WHEN indicators_missing > 0
           THEN 'MODERATE - both sides, but ' + toString(indicators_missing) + ' indicator(s) unloaded'
         WHEN origin_types = 2 AND sources >= 3 THEN 'GOOD - both sides, multiple sources'
         ELSE 'MODERATE'
       END AS confidence
ORDER BY sources_used, must_be_true;
