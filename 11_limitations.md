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

## 4. Three claims were overclaimed. They are now corrected.

Applied in `01c_evidence_revision.cypher`.

**Inventory +138% ⟶ throughput failed** — downgraded 3→2. Inventory growth is also what
deliberate scaling looks like. Separating the two needs a ratio, not a total.

**Inventory ⟶ liquidation speed** — downgraded 3→2. Direction is sound, magnitude is a
modelling judgement.

**Holding costs $5.3m vs $2.6m — edge removed entirely.** Worth understanding, because
the tempting correction is also wrong. It is *tempting* to normalise: 2.6/491.293 ≈ 0.53%
against 5.3/1,169.601 ≈ 0.45%, concluding efficiency improved. **That arithmetic is
invalid.** Holding costs are three-month flows (Q2 2020, Q2 2021); the inventory figures
are balance-sheet stocks at 31 Dec 2020 and 30 Jun 2021. Normalising Q2 2020 requires
inventory at *30 June 2020*, which we do not hold — and which was depressed by the COVID
buying suspension.

So we cannot show costs rose per unit, and we cannot show they fell. The item is
**uninterpretable with the evidence we have**, and it now bears on nothing. The node
stays in the graph, dated and real, flagged `HELD_NOT_INTERPRETABLE`.

No replacement edge was added. The "absolute exposure grew with scale" content is already
carried by the inventory edge to `A_FINANCING`; asserting it twice would double-count one
fact. *(Side note worth knowing: adding that edge would also have moved capital-light from
2 to 3 and failed acceptance test T5. It was dropped for the double-counting reason, and
T5 passes because `A_FINANCING` genuinely nets to zero at Q2 — cash +2, inventory −2 — not
because anything was arranged.)*

**What replaced it:** four `MissingEvidence` nodes naming what would settle each open
question — inventory turnover, the 30 June 2020 balance, normalised holding costs, and
realised forecast error. A decision system that lists the evidence it lacks is working,
not failing.

This is the clearest demonstration in the whole build that the graph can distinguish
**"the operation got bigger"** from **"the operation got worse."**

## 5. The honest headline

Not *"the Q2 evidence proved the bet was breaking."* The supported claim is:

> Between February and August, the assumptions that mattered most stayed unevidenced,
> and exposure to them roughly tripled.

`A_FORECAST` has zero evidence at **both** checkpoints. The governance failure is scaling
into something never verified — and that claim needs none of the contested Q2 readings.
