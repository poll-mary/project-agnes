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

- **Agent Memory Service overlaps with what a decision graph already does.** Our graph
  stores decisions, their rationale and their provenance as first-class nodes. Adding a
  separate memory service raises "which is the source of truth?" For this class of
  application the graph *is* the memory, and we'd want guidance on when the two are
  meant to compose rather than compete.

## Questions we'd have asked with more time

- Fine-grained RBAC is Enterprise, so the permissions story we care about most can't be
  prototyped on Aura Free. Is there a way to try label/property-level access control on
  a free instance, even toy-sized? That's the feature that would decide adoption for us.
