# Run sheet — what to click, what to say

**Three minutes. Five queries. All verified working in Aura on 25 Aug.**

Before you start: paste each query into a **new tab** in Aura beforehand so you're
switching tabs on stage, not pasting. Nothing worse than a paste failing live.

---

## 0:00–0:25 · The problem — no screen, just talk

> Companies make expensive bets using scattered and changing evidence.
>
> An LLM can generate an answer; our graph preserves the structure behind the decision
> and updates it over time.
>
> Zillow is our first controlled test of whether that structure creates real decision value.

> The question we set ourselves is small: **can a graph make the reasoning behind one
> decision visible, recomputable and responsive to new evidence?**

---

## 0:25–1:20 · `12_demo_monitor.cypher` — the centrepiece

> Six things had to be true for Zillow to scale iBuying. Here's each one, judged **only**
> on what was public on 10 February 2021 — and again on 5 August. I changed one date.
> Not the graph, not the model, not the prompt.

Point at three rows specifically:

- **Forward resale prices — NOT EVIDENCED at both dates.** "The most important assumption,
  and the public evidence never established it either way."
- **Working capital — supported (2) → mixed (0).** "In February the $3.9bn cash covered it.
  By August the inventory build had cancelled it out."
- **Consumer demand — supported (2) → supported (4).** "This one moved *up*. The graph
  isn't just a machine that worries."

---

## 1:20–1:50 · `13_demo_tripwire.cypher` — the pre-commitment

> A $1bn inventory guardrail, frozen on 10 February. In February there was nothing public
> to test it against. In August: $1.169bn, fired, reassess.
>
> Nothing in the graph stores whether it fired. That's computed at query time — storing
> the answer would be hindsight.

---

## 1:50–2:20 · `14_demo_scenarios.cypher` — the alternatives

> Same evidence, three ways of making the bet. Aggressive 21 → 33. Capital-light: **zero
> change.**
>
> That doesn't mean capital-light would have succeeded. The graph can't know how an
> unchosen strategy would have performed — only how it would currently be expected to.
> Capital-light didn't improve. It simply isn't exposed to what moved.

**If asked whether that's rigged:** capital-light is modelled in less depth than
aggressive, and a scenario modelled less thoroughly will look safer. Concede it directly.

---

## 2:20–2:45 · The missing-evidence query — the differentiator

*(section 4 of `01c_evidence_revision.cypher`)*

> This is what the graph doesn't know, and what would settle it. Realised forecast error.
> Inventory turnover. A summarizer can tell you what documents said. It can't tell you
> what they failed to say.

---

## 2:45–3:00 · Close

> We are not claiming the graph predicted Zillow. We're claiming that using only
> then-available evidence, it produced a traceable, decision-relevant change — and named
> which assumption caused it.
>
> Today proves the machinery works. It does not prove the product helps, and it does not
> prove the architecture predicts anything. That needs matched successes and failures,
> scored blind. That's next.

---

## Held in reserve for Q&A

**Acceptance tests** (`10_acceptance_tests_ONE_QUERY.cypher`) — seven checks that could
have failed. If anyone asks how you know it works rather than just tells a good story,
run this. It's the strongest thing you have.

**Prepared answers** — `07_supplement.md` and `11_limitations.md`.

**The two days that matter** — the FY2020 10-K sits in the graph dated 12 February, two
days after the checkpoint, and the query won't return it. Section 4 of `01b`.

---

## The five numbers to know cold

| | 10 Feb | 5 Aug |
|---|---|---|
| Aggressive principal | 21 | 33 |
| Hybrid | 11 | 15 |
| Capital-light | 2 | **2** |
| Evidence eligible | 4 | 8 |
| Tripwire | nothing to test | **FIRED** |
