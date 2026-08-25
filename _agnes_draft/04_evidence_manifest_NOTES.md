# Evidence manifest — notes

**Filings are on SEC EDGAR:** https://www.sec.gov/edgar/search/#/entityName=Zillow%20Group

The manifest records the source *document* for each fact rather than a deep-linked
accession URL. If there is spare time before the freeze, paste the exact accession
links in — but do not invent them. An unverified URL in an audit register is worse
than an honest document reference.

## The two days that matter

`ev_10k2020` has `public_from = 2021-02-12`. The FY2020 Form 10-K was filed **two days
after** the 10 February checkpoint, so it is **ineligible** at T0.

This is the single best illustration of the whole idea. A summariser handed "Zillow's
2020 annual report and the Q4 earnings release" would blend them without noticing.
The graph refuses, because the filing date is a property of the evidence and the
query filters on it.

It was also a genuine correction found while preparing the kit — the first draft
treated the 10-K as available at T0. Worth mentioning under "challenges encountered"
in the demo: the discipline caught a real error in our own work.
