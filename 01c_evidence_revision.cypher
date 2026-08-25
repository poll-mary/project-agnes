// =============================================================================
// 01c_evidence_revision.cypher — RUN AFTER 01 and 01b
//
// Corrects three overclaims. The graph must not assert more than the evidence
// supports, even when the weaker version tells a less dramatic story.
// =============================================================================


// --- 1. Inventory growth is not proof that throughput failed -----------------
// Inventory rising is ALSO what deliberate scaling looks like. Separating the
// two needs a ratio, not a total. Direction unchanged; confidence reduced.
MATCH (:Evidence {id:'E_Q2_INVENTORY'})-[r:BEARS_ON]->(:Assumption {id:'A_THROUGHPUT'})
SET r.weight = 2,
    r.reason = 'Inventory grew ~138% while 2,086 homes were sold. Consistent with throughput lagging acquisition, but also consistent with deliberate scaling. Inventory turnover / days-to-sale would separate the two and was not disclosed at this granularity.';

MATCH (:Evidence {id:'E_Q2_INVENTORY'})-[r:BEARS_ON]->(:Assumption {id:'A_LIQUIDITY'})
SET r.weight = 2,
    r.reason = 'A larger principal book is harder to liquidate quickly. Direction is sound; magnitude is a modelling judgement, not a measurement.';


// --- 2. The holding-cost item is UNINTERPRETABLE. Remove the edge. -----------
// $5.3m (Q2 2021) vs $2.6m (Q2 2020) are three-month flows. The inventory
// figures we hold are balance-sheet stocks at 31 Dec 2020 and 30 Jun 2021.
// Normalising Q2 2020 needs inventory at 30 JUNE 2020, which we do not have —
// and which was depressed because Zillow had suspended buying for COVID.
//
// So we cannot show that holding costs rose OR fell per unit of inventory.
// We delete the contradicting edge and add NO replacement: the "absolute
// exposure grew with scale" content is already carried by E_Q2_INVENTORY's
// edge to A_FINANCING, and asserting it twice double-counts one fact.
//
// The evidence node STAYS. It is real, dated, and in the graph — deliberately
// bearing on nothing. That is the honest state, and it is demonstrable.
MATCH (:Evidence {id:'E_Q2_HOLDING_COST'})-[r:BEARS_ON]->(:Assumption)
DELETE r;

MATCH (e:Evidence {id:'E_Q2_HOLDING_COST'})
SET e.status = 'HELD_NOT_INTERPRETABLE',
    e.note = 'Absolute holding costs rose with the size of the book. Whether cost PER UNIT of inventory rose or fell cannot be determined: the periods are mismatched (Q2 flows vs 31-Dec/30-Jun stocks) and the Q2 2020 baseline is distorted by the COVID buying suspension. Bears on no assumption until normalised.';


// --- 3. Name the evidence we do not have -------------------------------------
// A decision system that lists what would settle an open question is doing its
// job. These are first-class nodes, not comments.
CREATE CONSTRAINT missing_evidence_id IF NOT EXISTS
FOR (n:MissingEvidence) REQUIRE n.id IS UNIQUE;

UNWIND [
  {id:'M_TURNOVER', a:'A_THROUGHPUT',
   name:'Inventory turnover / days-to-sale for homes held',
   would_settle:'Whether inventory growth reflects scaling or an inability to resell.'},
  {id:'M_INV_JUN2020', a:'A_LIQUIDITY',
   name:'Homes inventory balance at 30 June 2020',
   would_settle:'Makes the Q2-2020 vs Q2-2021 holding-cost comparison computable at all.'},
  {id:'M_HOLDING_NORM', a:'A_LIQUIDITY',
   name:'Holding cost as a percentage of average inventory, matched periods',
   would_settle:'Whether the operation became less efficient, or merely larger.'},
  {id:'M_FORECAST_ERROR', a:'A_FORECAST',
   name:'Realised forecast error on homes purchased (offer price vs resale price)',
   would_settle:'The pricing assumption, which has NO evidence at either checkpoint.'}
] AS row
MERGE (m:MissingEvidence {id: row.id})
SET m.project = 'zillow_strategy_time_machine',
    m.name = row.name, m.would_settle = row.would_settle
WITH m, row
MATCH (a:Assumption {id: row.a})
MERGE (m)-[:WOULD_INFORM]->(a);


// --- 4. What the graph is missing, and why it matters ------------------------
// A good demo beat: the system says what it does not know and what would fix it.
MATCH (m:MissingEvidence)-[:WOULD_INFORM]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[:BEARS_ON]->(a) WHERE e.public_from <= date('2021-08-05')
WITH a, m, count(e) AS evidence_held
RETURN a.name AS assumption, evidence_held,
       m.name AS missing_evidence, m.would_settle AS would_settle
ORDER BY evidence_held, assumption;


// --- 5. Evidence present but deliberately not used ---------------------------
MATCH (e:Evidence) WHERE e.status = 'HELD_NOT_INTERPRETABLE'
RETURN e.title AS evidence, e.public_from AS public_from, e.note AS why_not_used;
