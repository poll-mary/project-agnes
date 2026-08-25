// ═══════════════════════════════════════════════════════════════
// PROJECT AGNES — the one question to ask live
//
// Change the date on line 1 and run it again. That is the demo.
// Nothing published after that date can appear in the answer.
// ═══════════════════════════════════════════════════════════════

WITH date('2021-08-05') AS cutoff

MATCH (a:Assumption {project:'zillow_strategy_time_machine'})
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= cutoff
    AND (e.public_until IS NULL OR e.public_until > cutoff)

WITH a,
     sum(CASE WHEN e.origin = 'INTERNAL' THEN 1 ELSE 0 END) AS zillow_said,
     sum(CASE WHEN e.origin = 'EXTERNAL' THEN 1 ELSE 0 END) AS the_world_said,
     sum(coalesce(r.direction,0) * coalesce(r.weight,0))    AS net

RETURN a.name AS what_had_to_be_true,
       zillow_said,
       the_world_said,
       CASE WHEN zillow_said + the_world_said = 0 THEN 'nobody has checked'
            WHEN net > 0 THEN 'holding up'
            WHEN net = 0 THEN 'mixed'
            ELSE              'IN TROUBLE' END AS where_it_stands,
       CASE WHEN zillow_said = 0
            THEN '<<<  ZILLOW NEVER PUBLISHED EVIDENCE FOR THIS'
            ELSE '' END AS silence
ORDER BY zillow_said, net;
