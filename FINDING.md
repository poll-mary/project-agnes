# The finding

## Measured, not argued

| | 10 Feb 2021 | 5 Aug 2021 |
|---|---|---|
| Assumptions with any evidence | 6/6 | 6/6 |
| Critical assumptions judged from one side only | 2 | 2 |
| Assumptions with a pre-committed trigger | **2/6** | **2/6** |
| Assumptions currently challenged | 4 | 4 |
| **Weight of evidence against the bet** | **10** | **18** |

**The evidence against the bet grew 80%. Nothing else moved.**

Six months. No gap closed, no guardrail added to any of the four unwatched assumptions,
the same two critical assumptions still judged from one side.

## Why this matters more than the Zillow story

**It requires no hindsight.** Standing on 5 August 2021, with only this table, the
statement is: *this decision is deteriorating and the process around it has not responded.*
No knowledge of the industry. No knowledge of the outcome. No prediction.

**It is domain-agnostic.** Every measure is about how the decision is being managed, not
about real estate. The same six numbers apply to a product launch, a market entry, an
acquisition.

**Counting would have missed it.** `assumptions_challenged` stayed at 4 across both dates.
The number of problems did not change — the same four got worse. A monitor that counted
issues would have reported "no change". Only the weighted view moved.

## The supporting findings

**The company never spoke to the assumption that killed it.** `A_FORECAST` — "forward
resale prices can be forecast within tolerable error" — is SILENT in Zillow's own filings
at both checkpoints. Every piece of evidence bearing on it is external. On 2 November 2021
the CEO named exactly this as the reason the business closed.

**External context saw the operational problem first.** In February, the Fed Beige Book's
labour and materials warning scored −2 against throughput; Zillow's own disclosures scored
−1. The world was a louder signal than the company, eight months before the company said
anything about capacity.

**A third of the evidence cuts both ways.** Six of eighteen evidence items support one
assumption while challenging another — a record-hot market makes held inventory appreciate
*and* puts a price-forecasting model outside anything it was calibrated on. A summary must
pick one reading. A graph holds both.

**Confidence is highest where it matters least.** Consumer demand — never the problem —
is the only assumption rated GOOD. Forecasting, the assumption that ended the business, is
MODERATE and one-sided. A known defect, recorded rather than hidden.

## What is not claimed

- Not that Agnes saw what Zillow could not. Zillow had vastly more data.
- Not that anyone would have acted differently.
- Not that pausing would have saved the money.
- Not that the architecture predicts anything. One case, no matched success, cannot
  separate "detects deterioration" from "pessimistic about everything".
- Not that the scenario comparison works. It is risk-only and can only ever prefer
  inaction. Found by our own sensitivity test, documented in `11_limitations.md`.
