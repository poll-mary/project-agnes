// =============================================================================
// 33_tensions.cypher — EVIDENCE THAT CUTS BOTH WAYS
//
// The graph-native insight, currently buried: one fact can support one
// assumption while challenging another. A record-hot housing market makes held
// inventory appreciate (good) AND puts a price-forecasting model outside any
// regime it was calibrated on (bad). Both true, from the same release.
//
// A flat summary must choose one reading. A graph holds both and names the
// tension. This is the clearest answer to "why not just summarise the
// documents?"
// =============================================================================

MATCH (e:Evidence)-[r:BEARS_ON]->(a:Assumption)
WHERE e.public_from <= date('2021-08-05')
  AND (e.public_until IS NULL OR e.public_until > date('2021-08-05'))
WITH e,
     collect(CASE WHEN r.direction = 1  THEN a.name END) AS supports_raw,
     collect(CASE WHEN r.direction = -1 THEN a.name END) AS challenges_raw,
     collect(CASE WHEN r.direction = 1  THEN r.reason END) AS why_support_raw,
     collect(CASE WHEN r.direction = -1 THEN r.reason END) AS why_challenge_raw
WITH e,
     [x IN supports_raw    WHERE x IS NOT NULL] AS supports,
     [x IN challenges_raw  WHERE x IS NOT NULL] AS challenges,
     [x IN why_support_raw WHERE x IS NOT NULL] AS why_support,
     [x IN why_challenge_raw WHERE x IS NOT NULL] AS why_challenge
WHERE size(supports) > 0 AND size(challenges) > 0
RETURN e.public_from AS published,
       e.origin AS origin,
       left(e.title, 44) AS the_same_fact,
       [x IN supports   | left(x, 30)] AS supports,
       [x IN challenges | left(x, 30)] AS challenges,
       left(why_challenge[0], 90) AS the_tension
ORDER BY published;
