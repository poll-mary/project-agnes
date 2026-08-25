# The blinded LLM contrast

**Cheap, high-impact, no dependencies. ~10 minutes. Do it before the core is finished
if you get a spare moment — it doesn't touch the graph.**

## Why

Sentence 2 of the pitch is *"an LLM can generate an answer; our graph preserves the
structure behind the decision."* This is how you **show** that instead of asserting it.

## The rule

Run Step 1 **before** you look at the Q2 numbers with the model. Once the August data is
in the context window the test is contaminated and worthless.

---

## Step 1 — the naked model

Fresh chat, no graph, no files:

> It is 10 February 2021. You know only what is publicly available on that date.
> Zillow Group is considering scaling Zillow Offers — buying homes directly, holding
> them, and reselling.
>
> List the assumptions that must hold for this to succeed, and assess each one against
> the evidence available as of 10 February 2021. State clearly where the evidence is
> insufficient.

**What to look for.** It will very likely leak the ending — hinting at inventory
problems, mispricing, or the November 2021 wind-down that it has no business knowing
about in February. Screenshot whatever it does. If it hedges, that's also a finding.

## Step 2 — run it twice more

Same prompt, fresh chats. **Compare the assumption lists.** They will differ in count,
wording and emphasis. That drift is the point: there is no persistent structure to
update, so every run re-invents the frame.

## Step 3 — the contrast

Put the naked output next to the T2 table from `03_demo_script.md`. Same question. One
drifts and leaks; the other returns the same six assumptions with states derived from
dated evidence.

---

## What to say

> Ask a language model this question and it already knows how the story ends — the
> wind-down is in its training data. It can't give you an uncontaminated answer, and
> asking it to pretend doesn't reliably work. Ask it three times and you get three
> different assumption sets.
>
> Our graph doesn't ask the model to forget. The post-cutoff evidence is in the
> database and the query doesn't return it. The model can't leak what it was never
> handed — and the structure is the same on every run.

## Honest caveat, if pressed

Training-data contamination is specific to backtesting — assessing a live 2027 bet has
no future to leak. But we need the date-gated version permanently anyway, because it's
the only way to **validate** the system at all. And in production the same boundary
carries a different predicate: provenance, recency, permissions.
