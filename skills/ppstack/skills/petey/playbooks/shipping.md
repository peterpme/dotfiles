### Shipping

1. Verify every PR independently at its current head with fresh `reviewer` runs and the best installed product-surface verifier. Record PASS, PASS WITH NOTES, FAIL, or UNAVAILABLE with evidence.
2. Walk from the lowest unmerged PR. Stop at the first missing or failing verdict. Only the contiguous verified run can land.
3. Recheck verdict head SHAs after restacks or new pushes. Reverify drift.
4. Arm Graphite merge-when-ready only with explicit landing authority. Never use GitHub auto-merge for child PRs in a stack.
5. Confirm arming from Graphite state. Do not infer it from a GitHub field.
6. Once the queue drains, stop mutating the stack. Watch through the existing PR watcher or Pi schedule. Diagnose stalls before changing refs.
7. Stop at the verified ceiling. Extending it requires a new verification pass.

Reply with the verified run, per-PR verdict and producer, arming evidence, landed PRs, and the next gap.
