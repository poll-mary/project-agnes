# What this does not do

The standard is whether the machinery does what we claim — not whether the Zillow story
reads well. These are the places it is weak. Say them before a judge finds them; being
caught is worse than owning it.

---

## 1. The score is an ordering heuristic, not a measurement

`criticality × (|negative balance| + 2 if no evidence)`.

**The `+2` is a magic number.** There is no principled reason it is 2 rather than 1 or 3.
It encodes a judgement — "an unevidenced critical assumption is roughly as alarming as a
moderately contradicted one" — and presents it as arithmetic.

What to say: *the score orders assumptions by how much attention they need. It is not a
probability and not a measurement. The ordering is the output; the number is scaffolding.*

Do not defend the 2. Concede it and point at the ordering.

## 2. `weight` conflates two different things

One number is doing the work of two: **how strong is this evidence** and **how much does
this assumption matter**. Those are separable and the model doesn't separate them.

Consequence: you cannot currently express "very strong evidence about something that
barely matters." A real version splits them.

## 3. One case, so we cannot rule out plain pessimism

This is the biggest one.

We have a single bet that failed. That means we **cannot distinguish** "the system detects
deterioration" from "the system is negative about everything you show it." One resolved
case cannot separate those.

There are two partial within-case controls, and they are worth pointing at:

- `A_DEMAND` stays positive at both cutoffs — the system does not condemn every assumption
- `S_CAPITAL_LIGHT` risk is identical at both cutoffs — the system does not move things the
  evidence doesn't touch

Both are checked in `10_acceptance_tests.cypher` (T4, T5). They are genuine but weak: they
show the machinery *can* stay flat, not that it discriminates across cases.

What to say: *the honest next step is matched cases — bets that succeeded and bets that
failed, scored blind. Until then this is an architecture demonstration, not evidence that
the architecture predicts anything.*

## 4. The evidence does not prove as much as it appears to

Three claims are weaker than they look, and the `reason` fields should say so:

- **Inventory +138% does not prove throughput failed.** Inventory can grow because you are
  deliberately scaling. The metric that would settle it — days-to-sale, or inventory
  turnover — was not disclosed at that granularity. *A decision system naming the evidence
  it lacks is doing its job.*
- **Holding costs $5.3m vs $2.6m is year-over-year against Q2 2020, the quarter iBuying
  was suspended for COVID.** The base is near-zero activity. Verify before saying it on
  stage; if it holds, this comparison proves very little.
- **Liquidity** — note that the kit already separates liquidation *speed* (`A_LIQUIDITY`)
  from cash *adequacy* (`A_FINANCING`), and routes the $3.9bn to the latter. That is
  correct. But the magnitude on the speed side is still a judgement call.

## 5. The honest headline

Not *"the Q2 evidence proved the bet was breaking."* The supported claim is:

> Between February and August, the assumptions that mattered most stayed unevidenced,
> and exposure to them roughly tripled.

`A_FORECAST` has zero evidence at **both** checkpoints. The governance failure is scaling
into something never verified — and that claim needs none of the contested Q2 readings.
