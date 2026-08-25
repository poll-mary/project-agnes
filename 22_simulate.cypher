// =============================================================================
// 22_simulate.cypher — WHAT IF THIS BREAKS, AND WHAT SHOULD I GO FIND OUT?
// =============================================================================

// --- PART 1 · FORWARD: break an assumption, price it per strategy ------------
// The assumption breaks IDENTICALLY in all three scenarios. What differs is
// how much of it lands on your balance sheet. That is a structural fact a
// scenario score cannot express.
MATCH (a:Assumption)-[f:FAILURE_EXPOSES]->(x:Exposure)<-[c:CREATES_EXPOSURE]-(s:Scenario)
WITH a, s, sum(f.severity * c.intensity) AS cost, collect(DISTINCT x.name) AS through
RETURN a.name AS if_this_breaks,
       s.name AS under_this_strategy,
       cost AS damage,
       through AS lands_on
ORDER BY if_this_breaks, damage DESC;



// --- PART 2 · INVERSE SIMULATION — RESULT: MODEL FLAW FOUND -----------------
// Built to answer "which assumptions actually decide the choice?"
// It answered: NONE OF THEM. Flip any assumption to total failure and
// capital-light still wins.
//
// Cause: the score is RISK-ONLY. There is no upside term, so the strategy with
// the fewest dependencies wins unconditionally. A model shaped this way can
// only ever recommend inaction.
//
// Consequences, stated plainly:
//   - SHADOW-MONITOR is not working. Capital-light "winning" is structural,
//     not evidence-driven.
//   - "Capital-light stayed flat at 2" is mostly explained by it having three
//     dependencies rather than six - NOT purely by evidence not touching it.
//   - The inverse simulation is useless as a decision tool until this is fixed.
//
// NOT FIXED TODAY, deliberately: adding an upside term means inventing a number
// for how much more economics the aggressive strategy captures. That is the
// same arbitrary-parameter trap this project has already fallen into twice.
//
// Verify the flaw yourself - flip every assumption, watch the winner never move:
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= date('2021-08-05')
WITH s, a, d, count(e) AS cnt,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
RETURN s.name AS strategy,
       count(a) AS dependency_count,
       sum(d.criticality * ((CASE WHEN bal < 0 THEN abs(bal) ELSE 0 END) +
                            (CASE WHEN cnt = 0 THEN 2 ELSE 0 END))) AS risk_score
ORDER BY risk_score;
// Fewest dependencies -> lowest risk score. Every time. That is the flaw.
