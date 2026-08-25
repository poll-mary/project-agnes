// =============================================================================
// 34_decision_health.cypher — DOMAIN-AGNOSTIC KPIs
//
// These measure how well the DECISION is being managed, not how the business
// is doing. No node ids, no dates, no domain terms. The same seven numbers
// apply to buying houses, launching a product, or entering a market.
//
// Domain KPIs (turnover, churn, CAC) belong to the business and cannot be
// agnostic. These belong to the decision process and must be.
// =============================================================================

MATCH (b:StrategicBet)-[:HAS_CHECKPOINT]->(c:Checkpoint)
WITH b, max(c.on) AS cut

MATCH (b)-[:CONSIDERS]->(:Scenario)-[dep:DEPENDS_ON]->(a:Assumption)
WITH b, cut, a, max(dep.criticality) AS criticality

OPTIONAL MATCH (e:Evidence)-[:BEARS_ON]->(a)
  WHERE e.public_from <= cut AND (e.public_until IS NULL OR e.public_until > cut)
WITH b, cut, a, criticality,
     count(DISTINCT e) AS sources,
     count(DISTINCT e.origin) AS breadth,
     max(e.public_from) AS newest

OPTIONAL MATCH (t:Tripwire)-[:MONITORS]->(:Exposure)<-[:FAILURE_EXPOSES]-(a)
WITH b, cut, a, criticality, sources, breadth, newest, count(DISTINCT t) AS watched

OPTIONAL MATCH (i:WorldIndicator {status:'NOT_LOADED'})-[:INFORMS]->(a)
WITH b, cut, a, criticality, sources, breadth, newest, watched, count(i) AS unloaded

WITH b, cut, count(a) AS n,
     sum(CASE WHEN sources > 0 THEN 1 ELSE 0 END)  AS evidenced,
     sum(CASE WHEN breadth = 2 THEN 1 ELSE 0 END)  AS both_sides,
     sum(CASE WHEN watched > 0 THEN 1 ELSE 0 END)  AS has_tripwire,
     sum(CASE WHEN sources = 0 AND criticality >= 3 THEN 1 ELSE 0 END) AS critical_blind,
     sum(CASE WHEN breadth < 2 AND criticality >= 3 THEN 1 ELSE 0 END) AS critical_onesided,
     sum(unloaded) AS blind_spots,
     min(duration.inDays(newest, cut).days) AS freshest_days

MATCH (b)-[:CONSIDERS]->(:Scenario)-[:DEPENDS_ON]->(aa:Assumption)
OPTIONAL MATCH (ev:Evidence)-[rr:BEARS_ON]->(aa)
WITH b, cut, n, evidenced, both_sides, has_tripwire, critical_blind, critical_onesided,
     blind_spots, freshest_days, ev,
     collect(DISTINCT rr.direction) AS dirs
WITH b, cut, n, evidenced, both_sides, has_tripwire, critical_blind, critical_onesided,
     blind_spots, freshest_days,
     sum(CASE WHEN size(dirs) = 2 THEN 1 ELSE 0 END) AS tensions

UNWIND [
  {k:'1 · Assumption coverage',      v:toString(evidenced)+'/'+toString(n),
   m:'assumptions with any eligible evidence'},
  {k:'2 · Source breadth',           v:toString(both_sides)+'/'+toString(n),
   m:'assumptions evidenced from BOTH inside and outside'},
  {k:'3 · Critical & unevidenced',   v:toString(critical_blind),
   m:'high-criticality assumptions with NO evidence at all'},
  {k:'4 · Critical & one-sided',     v:toString(critical_onesided),
   m:'high-criticality assumptions evidenced from only one side'},
  {k:'5 · Tripwire coverage',        v:toString(has_tripwire)+'/'+toString(n),
   m:'assumptions with a pre-committed trigger watching their exposure'},
  {k:'6 · Declared blind spots',     v:toString(blind_spots),
   m:'indicators declared relevant but carrying no data'},
  {k:'7 · Contested evidence',       v:toString(tensions),
   m:'evidence items that support one assumption and challenge another'}
] AS row
RETURN row.k AS kpi, row.v AS value, row.m AS meaning;
