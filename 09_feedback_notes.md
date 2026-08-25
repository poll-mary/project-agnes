# Feedback for Neo4j — what worked, what confused, what blocked

The brief asks for this explicitly: *"Note what worked, what was confusing, and what
blocked you. A finished production application is not required. A working experiment
and useful feedback are enough."*

**Add to this as things happen.** Reconstructing it at 17:00 produces bland notes;
capturing the moment of confusion produces useful ones. One line is enough.

---

## Worked

_(fill in as we go)_

## Confusing

- **Setup path assumes GitHub Codespaces + VS Code.** We're working locally on macOS
  with a different coding agent. Nothing in the checklist says whether that's supported
  or how the MCP config differs — we had to infer that "Neo4j MCP + `.env`" transfers
  unchanged. A one-line "works anywhere an MCP client runs" would have removed the doubt.

## Blocked

_(fill in as we go)_

## Product-fit observations

- **Agent Memory Service and a decision graph compose — but the split needs documenting.**
  Our first instinct was that they compete, because our graph already stores decisions and
  rationale. On reflection the clean division is by *audit requirement*: the graph holds
  the decision of record (bet, assumptions, evidence, who froze which threshold when),
  agent memory holds interaction state (this analyst always asks about liquidity first;
  we debated that framing last week). Anything that must survive an audit goes in the
  graph; anything that just makes the assistant less annoying goes in memory. We couldn't
  find guidance on this boundary and had to reason it out — a page on "when to use Agent
  Memory alongside a domain graph" would have saved us the detour.

## Questions we'd have asked with more time

- Fine-grained RBAC is Enterprise, so the permissions story we care about most can't be
  prototyped on Aura Free. Is there a way to try label/property-level access control on
  a free instance, even toy-sized? That's the feature that would decide adoption for us.
