// =============================================================================
// 35_health_trajectory.cypher — DID THE DECISION GET HEALTHIER?
//
// The snapshot says what state a decision is in. The trajectory says whether
// anyone acted on it.
//
// Between two checkpoints, exposure can grow while decision health stays flat.
// That is the pattern worth catching: not "the numbers got worse", but
// "the numbers got worse AND nothing was done to find out why".
//
// Fully domain-agnostic: no ids, no dates, no domain terms.
// =============================================================================

MATCH (b:StrategicBet)-[:HAS_CHECKPOINT]->(c:Checkpoint)
WITH b, c ORDER BY c.on
WITH b, collect(c.on) AS checkpoints
UNWIND checkpoints AS cut

MATCH (b)-[:CONSIDERS]->(:Scenario)-[dep:DEPENDS_ON]->(a:Assumption)
WITH b, cut, a, max(dep.criticality) AS crit

OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= cut AND (e.public_until IS NULL OR e.public_until > cut)
WITH b, cut, a, crit,
     count(DISTINCT e) AS sources,
     count(DISTINCT e.origin) AS breadth,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal

OPTIONAL MATCH (t:Tripwire)-[:MONITORS]->(:Exposure)<-[:FAILURE_EXPOSES]-(a)
  WHERE t.frozen_at <= cut
WITH b, cut, a, crit, sources, breadth, bal, count(DISTINCT t) AS watched

WITH cut,
     count(a) AS total,
     sum(CASE WHEN sources = 0 THEN 1 ELSE 0 END)                      AS unevidenced,
     sum(CASE WHEN breadth < 2 AND crit >= 3 THEN 1 ELSE 0 END)         AS critical_onesided,
     sum(CASE WHEN watched > 0 THEN 1 ELSE 0 END)                       AS watched_by_tripwire,
     sum(CASE WHEN bal < 0 THEN 1 ELSE 0 END)                           AS challenged,
     sum(CASE WHEN bal < 0 THEN abs(bal) ELSE 0 END)                    AS total_negative_weight

RETURN cut AS at_checkpoint,
       toString(total - unevidenced) + '/' + toString(total) AS evidenced,
       critical_onesided AS critical_one_sided,
       toString(watched_by_tripwire) + '/' + toString(total) AS tripwire_cover,
       challenged AS assumptions_challenged,
       total_negative_weight AS weight_of_negative_evidence
ORDER BY at_checkpoint;

// READ IT LIKE THIS:
//   evidenced / tripwire_cover going UP  = someone is closing gaps
//   evidenced / tripwire_cover going FLAT while
//   weight_of_negative_evidence goes UP  = exposure grew, nobody investigated
//
// The second pattern is the governance failure. It is measurable, it needs no
// knowledge of the industry, and it is visible BEFORE the outcome.
