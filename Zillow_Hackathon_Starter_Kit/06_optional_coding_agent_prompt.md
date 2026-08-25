# Optional Coding-Agent Prompt

Use this only after `01_seed_graph.cypher` and the cutoff queries work directly in Neo4j.

## Prompt

I am at a one-day Neo4j hackathon. Build the smallest possible demo interface for an existing Aura graph. Do not redesign the ontology, generate new evidence, add authentication, or create production architecture.

The graph is already seeded with:

- `StrategicBet`
- `Scenario`
- `Assumption`
- `Evidence` with a `public_from` Neo4j date
- `Exposure`
- `Tripwire`
- `MetricObservation`

The interface needs exactly:

1. A cutoff selector with two values: `2021-02-10` and `2021-08-05`.
2. A button that runs the existing as-known-at query using the selected cutoff.
3. A simple result showing:
   - ranked assumptions;
   - eligible evidence titles;
   - scenario structural-risk signal;
   - tripwire state.
4. A source link for each evidence item.
5. A visible disclaimer: “Prototype decision-support output; not a prediction or financial advice.”

Use the fastest framework already supported in this environment. Keep the Neo4j URI, username and password in environment variables. Never hard-code credentials. Do not add dependencies unless they are essential. First inspect the environment and existing starter files, then state the smallest implementation plan before editing.

Success means the demo works reliably for the two cutoff dates. Styling is secondary. If an interface cannot be completed quickly, stop and preserve the working Neo4j Browser demo.

