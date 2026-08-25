// ═══════════════════════════════════════════════════════════════
// LIVE QUESTIONS — for the demo
//
// Run ONE of these at a time. Each answers something the slides
// cannot. If someone asks "why a graph?", run Q4.
// ═══════════════════════════════════════════════════════════════


// ───────────────────────────────────────────────────────────────
// Q0 · THE PICTURE — start the demo with this one on screen
// ───────────────────────────────────────────────────────────────
MATCH p=(b:StrategicBet {project:'zillow_strategy_time_machine'})-[*1..3]-(x)
RETURN p LIMIT 200;


// ───────────────────────────────────────────────────────────────
// Q1 · "What did they know on <any date>?"
//      Change the date. Nothing published later can appear.
// ───────────────────────────────────────────────────────────────
WITH date('2021-05-11') AS cutoff
MATCH (a:Assumption {project:'zillow_strategy_time_machine'})
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a)
  WHERE e.public_from <= cutoff
    AND (e.public_until IS NULL OR e.public_until > cutoff)
WITH a, cutoff,
     sum(coalesce(r.direction,0) * coalesce(r.weight,0)) AS net,
     count(r) AS items
RETURN a.name AS must_be_true,
       items  AS evidence_items,
       net    AS net_support,
       CASE WHEN items = 0 THEN 'NOBODY HAS CHECKED'
            WHEN net > 0   THEN 'holding up'
            WHEN net = 0   THEN 'mixed'
            ELSE                'in trouble' END AS state
ORDER BY net;


// ───────────────────────────────────────────────────────────────
// Q2 · "Which facts point BOTH ways?"
//      One event that supports one belief and undermines another.
//      A spreadsheet column cannot hold this.
// ───────────────────────────────────────────────────────────────
MATCH (e:Evidence)-[r:BEARS_ON]->(a:Assumption)
WITH e, collect(DISTINCT r.direction) AS dirs,
     collect(CASE WHEN r.direction > 0 THEN '+ ' + a.name
                  ELSE '- ' + a.name END) AS bearings
WHERE size(dirs) > 1
RETURN e.public_from AS published, e.title AS fact, bearings
ORDER BY published;


// ───────────────────────────────────────────────────────────────
// Q3 · "What did Zillow itself never talk about?"
//      Assumptions with outside evidence but NO company evidence.
// ───────────────────────────────────────────────────────────────
MATCH (a:Assumption {project:'zillow_strategy_time_machine'})
OPTIONAL MATCH (i:Evidence {origin:'INTERNAL'})-[:BEARS_ON]->(a)
OPTIONAL MATCH (x:Evidence {origin:'EXTERNAL'})-[:BEARS_ON]->(a)
WITH a, count(DISTINCT i) AS from_zillow, count(DISTINCT x) AS from_world
RETURN a.name AS must_be_true, from_zillow, from_world,
       CASE WHEN from_zillow = 0 THEN '>>> ZILLOW NEVER SAID A WORD' ELSE '' END AS flag
ORDER BY from_zillow, from_world DESC;


// ───────────────────────────────────────────────────────────────
// Q4 · THE ANSWER TO "why a graph?"
//      One fact → the belief it damages → what that exposes →
//      which strategies depend on it. Four hops. This is the join
//      that a spreadsheet has to be rebuilt by hand to answer.
// ───────────────────────────────────────────────────────────────
MATCH (e:Evidence)-[r:BEARS_ON]->(a:Assumption)-[f:FAILURE_EXPOSES]->(x:Exposure)
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a)
WHERE r.direction < 0
RETURN e.title       AS the_fact,
       a.name        AS damages_this_belief,
       x.name        AS which_exposes_us_to,
       s.name        AS in_this_strategy,
       d.criticality AS how_critical
ORDER BY d.criticality DESC, e.public_from
LIMIT 15;


// ───────────────────────────────────────────────────────────────
// Q5 · THE FRAME IS NOT ABOUT HOUSES
//      Six domain-neutral slots; Zillow's answers are one filling.
//      (Needs 50_universal_layer.cypher to have been run.)
// ───────────────────────────────────────────────────────────────
MATCH (s:UniversalSlot)
OPTIONAL MATCH (a:Assumption)-[:FILLS]->(s)
RETURN s.ordinal AS n, s.slot AS asked_of_any_project,
       s.question AS the_question,
       coalesce(a.name,'—') AS zillow_had_to_answer
ORDER BY n;
