# What is Git?

Git is a distributed version control system born in 2005 out of the Linux kernel community. It was created by Linus Torvalds to manage source code at scale after proprietary tools proved too slow for thousands of contributions. Designed for speed and integrity, Git quickly became the backbone of modern open-source collaboration.

![image_gen: Git's origin in the Linux kernel community]

The core flow in Git revolves around local commits and remote repositories. Developers create branches to isolate work, commit changes as snapshots, and merge those branches back into the main line once the work is reviewed. Every commit is cryptographically hashed, giving each change a unique identity that can be shared or rolled back at any time.

![image_gen: Branching and merging workflow with commits flowing back to main]

In the Codex deployer, Git plays a central role. The dispatcher pulls repositories directly, applies feedback as commits, and pushes updates for review. By treating the repo as the source of truth, Codex can reason about each deployment cycle, generate patches, and continuously refine services without manual pipelines.

*Figure 1: Git's evolution from a patch management tool to the standard version control system.*

*Figure 2: The branching flow used by Codex deployer to orchestrate code updates.*

```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```
