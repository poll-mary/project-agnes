// ─────────────────────────────────────────────────────────────
// 50 — The project-agnostic layer
//
// Every strategic bet is "we do X, expecting Y". Six things must
// hold for that to work, and none of them mention money, customers
// or units. Those six are the UNIVERSAL slots.
//
// A project fills each slot with its own concrete assumption.
// Zillow's six are one filling. A rail line, a drug trial or a
// system migration would fill the same six slots differently.
//
// Nothing about the graph structure changes. This adds the layer
// above the Zillow wording so the model can be pointed at anything.
// ─────────────────────────────────────────────────────────────

// 1. The six universal slots — domain-neutral, reusable across projects
UNWIND [
  {slot:'READING',       ord:1, q:'Is what we believe about the world actually true?'},
  {slot:'CAPABILITY',    ord:2, q:'Can we actually do the thing?'},
  {slot:'ENDURANCE',     ord:3, q:'Can we keep doing it long enough to find out?'},
  {slot:'PAYOFF',        ord:4, q:'Is it worth more than what it costs us?'},
  {slot:'COOPERATION',   ord:5, q:'Will the parties outside our control do their part?'},
  {slot:'REVERSIBILITY', ord:6, q:'If we are wrong, can we get out?'}
] AS row
MERGE (s:UniversalSlot {slot: row.slot})
SET s.ordinal = row.ord,
    s.question = row.q;

// 2. Attach Zillow's six assumptions to the slots they fill
UNWIND [
  {id:'A_FORECAST',   slot:'READING'},
  {id:'A_THROUGHPUT', slot:'CAPABILITY'},
  {id:'A_FINANCING',  slot:'ENDURANCE'},
  {id:'A_UNIT',       slot:'PAYOFF'},
  {id:'A_DEMAND',     slot:'COOPERATION'},
  {id:'A_LIQUIDITY',  slot:'REVERSIBILITY'}
] AS row
MATCH (a:Assumption {id: row.id, project:'zillow_strategy_time_machine'})
MATCH (s:UniversalSlot {slot: row.slot})
MERGE (a)-[:FILLS]->(s)
SET a.universal_slot = row.slot;

// 3. Check — every slot filled exactly once, no assumption left over
MATCH (s:UniversalSlot)
OPTIONAL MATCH (a:Assumption {project:'zillow_strategy_time_machine'})-[:FILLS]->(s)
RETURN s.ordinal            AS n,
       s.slot               AS universal_slot,
       s.question           AS the_question_for_any_project,
       coalesce(a.name,'— UNFILLED —') AS how_zillow_answered_it
ORDER BY n;
