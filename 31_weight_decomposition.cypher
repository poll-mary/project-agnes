// =============================================================================
// 31_weight_decomposition.cypher — MAKE THE JUDGEMENT VISIBLE
//
// PROBLEM: every BEARS_ON.weight is a single hand-picked number doing two
// different jobs at once - "how authoritative is this source" and "how much
// does it bear on THIS assumption". Roughly thirty invented numbers, with the
// judgement invisible inside them.
//
// FIX: split them.
//   authority  - DERIVED from the source type. Rule-based, no judgement.
//   relevance  - DECLARED per edge. Judgement, but now explicit and auditable.
//   weight     = authority x relevance, normalised to 1..3
//
// This does not remove judgement. It makes half the number mechanical and
// forces the other half into the open where it can be argued with.
//
// NOTE ON WHY RELEVANCE CANNOT BE DERIVED: specificity is relative to the
// ASSUMPTION, not the company. A national price index is weak evidence about
// this company's throughput and strong evidence about whether market prices
// are forecastable. Same source, different relevance, same edge type. That is
// irreducibly a judgement - so we surface it rather than pretend otherwise.
// =============================================================================

// --- 1. Authority, derived from what kind of source it is -------------------
MATCH (e:Evidence) WHERE e.project = 'zillow_strategy_time_machine'
SET e.source_authority =
  CASE
    WHEN e.id STARTS WITH 'E_' AND (e.title CONTAINS '10-K' OR e.title CONTAINS '10-Q')
      THEN 3   // audited regulatory filing
    WHEN e.id STARTS WITH 'E_'
      THEN 2   // company earnings release: company-authored, not audited
    WHEN e.publisher IN ['S&P Dow Jones Indices','National Association of Realtors',
                         'Federal Reserve Beige Book','Freddie Mac PMMS']
      THEN 3   // official statistical or central-bank source
    WHEN e.publisher = 'Opendoor Technologies'
      THEN 3   // competitor regulatory filing
    ELSE 2     // commercial data provider
  END,
  e.authority_basis =
  CASE
    WHEN e.id STARTS WITH 'E_' AND (e.title CONTAINS '10-K' OR e.title CONTAINS '10-Q')
      THEN 'audited regulatory filing'
    WHEN e.id STARTS WITH 'E_' THEN 'company earnings release, unaudited'
    WHEN e.publisher = 'Opendoor Technologies' THEN 'competitor regulatory filing'
    WHEN e.publisher IS NULL THEN 'unclassified'
    ELSE 'official statistical source'
  END;

// --- 2. Relevance: carry across the existing declared weight ----------------
// The current weight WAS a relevance judgement with authority baked in.
// Preserve it as the declared relevance so nothing silently changes, and flag
// which edges have never been reviewed under the new scheme.
MATCH (:Evidence)-[r:BEARS_ON]->(:Assumption)
WHERE r.relevance IS NULL
SET r.relevance = r.weight,
    r.relevance_reviewed = false;

// --- 3. What the split reveals ----------------------------------------------
// Where authority and declared relevance disagree, the old single number was
// hiding something. Those edges are the ones worth re-examining first.
MATCH (e:Evidence)-[r:BEARS_ON]->(a:Assumption)
RETURN e.authority_basis AS source_type,
       count(r) AS edges,
       avg(e.source_authority) AS avg_authority,
       avg(r.relevance) AS avg_declared_relevance,
       sum(CASE WHEN e.source_authority > r.relevance THEN 1 ELSE 0 END)
         AS authoritative_but_low_relevance,
       sum(CASE WHEN r.relevance > e.source_authority THEN 1 ELSE 0 END)
         AS weak_source_but_high_relevance
ORDER BY edges DESC;
