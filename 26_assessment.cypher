// =============================================================================
// 26_assessment.cypher — WHAT AGNES KNOWS, AND WHERE SHE LEARNED IT
//
// Separates the company's own disclosures from the world around it, at both
// checkpoints. Eligibility now honours supersession:
//     public_from <= cutoff AND (public_until IS NULL OR public_until > cutoff)
//
// Read the A_FORECAST row first. That is the assumption Rich Barton named on
// 2 November 2021 as the reason the business closed.
// =============================================================================

UNWIND [date('2021-02-10'), date('2021-08-05')] AS cut
MATCH (a:Assumption) WHERE a.project = 'zillow_strategy_time_machine'

OPTIONAL MATCH (ei:Evidence {origin:'INTERNAL'})-[ri:BEARS_ON]->(a)
  WHERE ei.public_from <= cut AND (ei.public_until IS NULL OR ei.public_until > cut)
WITH cut, a, count(ei) AS i_n,
     sum(CASE WHEN ei IS NULL THEN 0 ELSE ri.direction * ri.weight END) AS i_bal

OPTIONAL MATCH (ex:Evidence {origin:'EXTERNAL'})-[rx:BEARS_ON]->(a)
  WHERE ex.public_from <= cut AND (ex.public_until IS NULL OR ex.public_until > cut)
WITH cut, a, i_n, i_bal, count(ex) AS x_n,
     sum(CASE WHEN ex IS NULL THEN 0 ELSE rx.direction * rx.weight END) AS x_bal

WITH a, cut, i_n, i_bal, x_n, x_bal, i_bal + x_bal AS total,
     CASE WHEN i_n = 0 THEN 'SILENT' ELSE toString(i_bal) END AS filings,
     CASE WHEN x_n = 0 THEN 'silent' ELSE toString(x_bal) END AS world

WITH a.name AS must_be_true,
     max(CASE WHEN cut = date('2021-02-10') THEN filings END) AS feb_filings,
     max(CASE WHEN cut = date('2021-02-10') THEN world   END) AS feb_world,
     max(CASE WHEN cut = date('2021-08-05') THEN filings END) AS aug_filings,
     max(CASE WHEN cut = date('2021-08-05') THEN world   END) AS aug_world,
     max(CASE WHEN cut = date('2021-08-05') THEN total   END) AS aug_total
RETURN left(must_be_true, 52) AS must_be_true,
       feb_filings, feb_world, aug_filings, aug_world,
       CASE WHEN feb_filings = 'SILENT' AND aug_filings = 'SILENT'
            THEN '<<< company never spoke to this'
            ELSE '' END AS note
ORDER BY note DESC, must_be_true;
