# Decision Log — Project Thermodynamics Path C

## 2026-06-09

Decision: Use Life / org / Work three-layer management.

- Life parent Issue: [kiwamust/life#29](https://github.com/kiwamust/life/issues/29)
- org execution Issues: [#14](https://github.com/kiwamust/org/issues/14), [#16](https://github.com/kiwamust/org/issues/16), [#22](https://github.com/kiwamust/org/issues/22), [#20](https://github.com/kiwamust/org/issues/20)
- Work remains the theory and artifact store.

Rationale:

- Life already has the project-level QCD Issue.
- org should track Path C execution tasks and quality gates.
- Work should preserve T0-T6, Handoff Package, baseline data, and validation outputs.

Decision: Normalize Path C labels before collection.

- Replace `org:phase/active` with `org:phase/execute`.
- Do not use `org:status/active`.
- Define WIP as open issues with `org:phase/execute`.
- Use RAG labels `org:status/green|yellow|red`.

