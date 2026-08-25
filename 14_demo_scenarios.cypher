// THREE WAYS TO MAKE THE SAME BET — scored on identical evidence, both dates.
// This is a MODEL SCORE, not a risk measurement and not a probability.
// Lower = less exposed under the assumptions we have actually represented.
UNWIND [date('2021-02-10'), date('2021-08-05')] AS cutoff
MATCH (s:Scenario)-[d:DEPENDS_ON]->(a:Assumption)
OPTIONAL MATCH (e:Evidence)-[r:BEARS_ON]->(a) WHERE e.public_from <= cutoff
WITH cutoff, s, a, d, count(e) AS cnt,
     sum(CASE WHEN e IS NULL THEN 0 ELSE r.direction * r.weight END) AS bal
WITH cutoff, s,
     sum(d.criticality * ((CASE WHEN bal < 0 THEN abs(bal) ELSE 0 END) +
                          (CASE WHEN cnt = 0 THEN 2 ELSE 0 END))) AS score
WITH s.name AS how_you_make_the_bet,
     max(CASE WHEN cutoff = date('2021-02-10') THEN score END) AS on_10_feb,
     max(CASE WHEN cutoff = date('2021-08-05') THEN score END) AS on_05_aug
RETURN how_you_make_the_bet, on_10_feb, on_05_aug,
       on_05_aug - on_10_feb AS change
ORDER BY on_05_aug;
