# External context, 2021 — the research

**Why this matters:** internal data tells you how you are doing. External data tells you
whether the world is about to stop cooperating. Zillow had far more internal data than our
graph will ever hold. What follows is the *outside* picture, which is where a decision
system can actually add something.

---

## The finding that reframes the whole project

On 2 November 2021, CEO Rich Barton explained the shutdown:

> "We've determined the unpredictability in forecasting home prices far exceeds what we
> anticipated."

**That is `A_FORECAST` — the exact assumption our graph flags as NOT EVIDENCED at both
checkpoints.** The thing that killed the bet is the thing the graph said nobody had
established, in February *and* in August.

We did not tune anything to produce that. It came out of asking which assumptions had zero
eligible evidence.

Zillow bought ~7,000 homes across 25 metros, lost $500m+, and cut 25% of staff.

---

## The signal that was publicly computable all along

Bank of America analysed **300+ properties Zillow Offers had bought**, using only public
data — purchase prices from records, current listings, historical local appreciation:

- Austin: Zillow paid prices implying **27% annual appreciation**, against a ~6% historical norm
- Sacramento, Portland, Cincinnati, Tampa, Phoenix, Denver: **>20% per year** run-ups
- Zillow then had to discount listings by **~6%** on average
- Net: roughly a **2% loss** across the sample at then-current listing prices

Their conclusion: *Zillow may be purchasing speculative houses at risk of price deflation
in a downturn.*

**The honest point, and the limit of it.** We could not establish when BofA circulated
this — the Fortune write-up is dated 3 November, the day after the shutdown, and gives no
date for the underlying research. **So we cannot claim anyone published a warning first.**

What we *can* claim, and it is the stronger claim anyway: **the method needed no
privileged information.** Purchase prices are public record. Listing prices are public —
they are on Zillow's own website. Historical appreciation is public. This comparison was
computable, by an outsider, monthly, throughout 2021.

The industry name for it is the **buy-to-list premium**: purchase price versus current
list price. Analysts describe it as the best leading indicator of whether an iBuyer is
pricing well. Opendoor's was rising and healthy through 2021. Zillow's went negative.

So: the evidence that would have settled the one assumption the graph flagged as
unevidenced **existed publicly the entire time, and nobody in the decision loop was
computing it.** That is a monitoring failure, not an information failure — and monitoring
failure is precisely what Agnes exists to prevent.

---

## Dated external timeline

| Date | External fact | Bears on |
|---|---|---|
| Jan 2021 | Mortgage rates at record lows (~2.65%) | demand tailwind |
| Spring 2021 | Bidding wars at all-time high; fastest price growth in recorded US history | *favourable* — removes the macro excuse |
| **28 May 2021** | **Lumber peaks at $1,515/1,000bf, ~300% up YoY** | renovation cost, throughput |
| May 2021 | New home construction −8.8% and home improvement −8.1% from March highs — demand destroyed by input costs | throughput |
| Jul 2021 | Lumber down **49%** from peak, to ~$770 | violent input-cost volatility |
| 20 Aug 2021 | Lumber at **$399**, from $1,515 in May | — |
| Through 2021 | Sawmill and construction **labour shortages** limiting capacity | throughput |
| Aug 2021 | Case-Shiller YoY peaks at **19.8%** (Aug-20→Aug-21 window), then decelerates | the turn |
| Summer 2021 | Market began slowing; **Zillow did not slow with it** | the decision gap |
| 2 Nov 2021 | Shutdown: $500m+ loss, 25% of staff, ~7,000 homes | outcome |

---

## The publication-lag problem — and why the ontology already handles it

**Case-Shiller runs roughly two months behind.** The August 2021 reading — the peak, and
the first sign of deceleration — was not published until late October 2021.

So an outside observer on 5 August **could not** have seen the deceleration in
Case-Shiller. It had happened, but it was not yet knowable.

This is exactly the `valid_at` versus `public_from` distinction already in the kit's
`MetricObservation`. A point-in-time system must model *when a fact became available*, not
when it was measured. Getting this wrong is how backtests lie to you.

It also explains why the fast indicators matter more: lumber trades daily, listings update
daily, county records file continuously. Case-Shiller is a rear-view mirror.

---

## What this means for Agnes

**Market data is a comparator, not a denominator.** The 2021 housing market was the most
favourable in modern history — record appreciation, record-low rates, bidding wars. That
does **not** prove Zillow's throughput failed. It does something else, and it is worth
more:

> Zillow was losing money and accumulating inventory in the best conditions the business
> would ever see. So "the market turned against us" does not explain it.

That kills the macro excuse. It does not establish an operational failure — only
Zillow-specific turnover, inventory-age and days-to-resale data could do that, and that is
what our `MissingEvidence` nodes already name.

**External data belongs in three roles, and they should not be confused:**

1. **Comparator** — was the environment helping or hurting? (Case-Shiller, rates)
2. **Input-cost signal** — does the operating assumption still hold? (lumber, labour)
3. **Realised-outcome proxy** — is the pricing model actually working? (buy-to-list premium)

Only the third is a genuine leading indicator of the assumption that killed them. And it
was public.

---

## Sources

- [Stanford GSB — Flip Flop: Why Zillow's Algorithmic Home Buying Venture Imploded](https://www.gsb.stanford.edu/insights/flip-flop-why-zillows-algorithmic-home-buying-venture-imploded)
- [Axios — Zillow will abandon home-flipping algorithm](https://www.axios.com/2021/11/02/zillow-abandon-home-flipping-algorithm)
- [Fortune — Zillow overpaid; Bank of America analysis](https://fortune.com/2021/11/03/zillow-house-flipping-overpaid-offers-unit-bank-of-ameria/)
- [Mike DelPrete — Opendoor vs Zillow: A Tale of Two Pricing Models](https://www.mikedp.com/articles/2021/12/16/opendoor-vs-zillow-a-tale-of-two-pricing-models)
- [Inman — Pricing is a competitive advantage for iBuyers](https://www.inman.com/2021/12/20/opendoor-vs-zillow-pricing-is-a-competitive-advantage-for-ibuyers/)
- [Fortune — Lumber price falls to $399, down from $1,515 this spring](https://fortune.com/2021/08/20/lumber-prices-rates-shortage-diy-projects-home-depot-lowes/)
- [Fortune — Lumber prices down 49% from the peak](https://fortune.com/2021/07/07/lumber-prices-2021-chart-update-july-price-of-lumber-falling-wood-costs/)
- [Construction Dive — Why lumber prices are spiking](https://www.constructiondive.com/news/lumber-demand-shortage-price-saw-mill-board-housing-pandemic-labor/601054/)
- [Fortune — The Great Deceleration](https://fortune.com/2022/01/04/great-deceleration-housing-price-appreciation-will-slow/)
- [SEC — Zillow Group Q3 2021 Form 10-Q](https://www.sec.gov/Archives/edgar/data/1617640/000161764021000087/z-20210930.htm)
