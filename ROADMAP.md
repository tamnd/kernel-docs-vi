# Roadmap

This document outlines the planned phases of the project. It is not a
binding plan and carries no fixed deadlines. Items are checked off as
completed, and the document is revised when priorities shift.

## Completed

- Imported `Documentation/` from torvalds/linux master at commit
  `8541d8f`.
- Implemented four scripts under `scripts/`: `init-upstream.sh`,
  `sync-upstream.sh`, `diff-upstream.sh`, and `translation-status.sh`.
  All use a blobless, shallow, sparse partial clone so that upstream
  synchronization does not require fetching the entire kernel tree.
- Authored project-level documentation: README, CONTRIBUTING,
  TRANSLATORS, and a stub `index.rst` under `vi_VN/`.
- Set up automated generation of `TRANSLATION_STATUS.md`.
- Published the repository publicly at
  https://github.com/tamnd/kernel-docs-vi.

## Phase 1: Foundation

Before substantial translation work begins, several foundational
elements need to be in place to avoid downstream rework.

### disclaimer-vi.rst

Every kernel translation branch (zh_CN, ja_JP, it_IT, and others)
ships a short disclaimer that is included at the top of each
translated page. Its purpose is to establish precedence: when the
translation and the original diverge, the original is authoritative.
The fastest path is to copy `zh_CN/disclaimer-zh_CN.rst` and adapt
the wording for Vietnamese.

### GLOSSARY.md

Terminology must be standardized early. Three categories require
classification:

1. Terms kept in English: kernel, userspace, process, thread,
   syscall, driver, module, scheduler, interrupt, RCU, spinlock,
   memory barrier, bootloader, BIOS. Vietnamese technical writing
   conventionally preserves these terms in their original form;
   forced translation typically reduces readability.
2. Terms translated directly: system, file, directory, permission,
   error. These terms have well-established Vietnamese equivalents
   with no ambiguity.
3. Terms requiring an explicit decision: lock, queue, buffer, pipe.
   Either approach is defensible for each of these; consistency
   across the repository is more important than the particular
   choice.

The glossary is maintained as a three-column table (English,
Vietnamese, notes) and expanded incrementally as new terms are
encountered during translation work.

### First translation: process/howto.rst

This file is the entry point for kernel development. Its absence
from the Vietnamese translation leaves the project without a visible
starting point for new contributors. The file is substantial in
length but low in technical density, which makes it a suitable
candidate for establishing conventions on cross-references, code
blocks, and the boundary between translated prose and preserved
English identifiers.

### admin-guide/README.rst and admin-guide/index.rst

These files serve as the entry point for kernel users rather than
developers. They are short and practical. Translating them in
parallel with `howto.rst` ensures both target audiences have initial
content from the outset.

## Phase 2: Expanding coverage

Priority ordering reflects expected utility for Vietnamese-speaking
readers:

1. `process/`. Coding style, patch submission, email client
   configuration, and the maintainer handbook. This section is the
   primary reference for contributors working with upstream.
2. Common pages under `admin-guide/`: kernel-parameters,
   bootloaders, module signing, sysctl, and the troubleshooting
   guides.
3. `core-api/`. Memory management, locking, and concurrency
   primitives. This background material has relevance beyond kernel
   development.
4. `dev-tools/`. kgdb, kasan, ftrace, perf. High practical utility
   across a broad user base.
5. `filesystems/`, `networking/`, `scheduler/`. Prioritization is
   driven by contributor interest rather than alphabetical order.

The project does not set a quantitative target for files translated
per month. A small number of well-executed translations is preferable
to bulk output at reduced quality, since a single poor translation
undermines reader confidence in the broader body of work.

## Phase 3: Automation

Once translation coverage reaches a meaningful scale (approximately
several dozen files), the following tooling becomes worth
implementing.

### Drift tracking

When the upstream version of a translated file is modified after the
Vietnamese translation has been merged, the translation begins to
diverge from the source. A tracking mechanism is required to
identify, for each translated file, the upstream SHA against which
the translation was performed, and the distance between that SHA and
the current state of upstream.

A straightforward implementation is to include a metadata line at
the top of each translated file:

```
:Upstream-at: 8541d8f725c6
```

A script traverses the translation tree, compares each file's
`Upstream-at` value against the current `UPSTREAM` commit, and emits
a list of files requiring review. Precision is not required; the
mechanism serves as an early warning rather than a definitive signal.

### Continuous integration

GitHub Actions is sufficient for the project's needs; no heavier
infrastructure is warranted.

- Execute `scripts/translation-status.sh` on every merge and every
  upstream synchronization, and commit the updated
  `TRANSLATION_STATUS.md` when changes are detected.
- Perform basic RST linting. A full Sphinx build would provide
  additional verification but is not required at the current stage.
- Verify that translated files retain their `SPDX-License-Identifier`
  header. This is a kernel-wide invariant that can be inadvertently
  removed during copy operations.
- Verify that translated files include an `:Original:` directive
  pointing to the source file.

### Sphinx build verification

Execute `make htmldocs` scoped to `vi_VN/` to confirm that the
translation's toctree builds correctly. With only `index.rst` in
place, the test value is limited; once approximately a dozen pages
exist, integrating this step into the workflow prevents accumulated
build errors.

## Phase 4: Community

This phase carries the greatest uncertainty. Translation work by a
single contributor is slow and prone to burnout; additional
contributors are required for sustained progress. Practical
approaches:

- Publish a project introduction covering context, goals, and
  contribution process. Distribution channels include Vietnamese
  developer communities (Daynhauhoc, Facebook groups focused on
  Linux and open source, and internal forums of companies operating
  in kernel and embedded development).
- Designate short and accessible files as `good first translation`
  within `TRANSLATION_STATUS.md` or in a dedicated document, as a
  standard onboarding mechanism for new contributors.
- Maintain a review turnaround of a few days for incoming pull
  requests. Extended review delays discourage first-time
  contributors from returning.
- Accept small pull requests. One file per pull request is preferred
  over batched submissions, as smaller pull requests are easier to
  review and less intimidating for new contributors.

Expectations should be calibrated realistically. Translation of
kernel documentation offers no financial compensation, institutional
recognition, or external deadline pressure. Sustained participation
is limited to contributors with genuine interest in the subject
matter, a population that is not large in Vietnam.

## Out of scope

The following are explicitly excluded from the project's scope:

- Translation of source code comments and docstrings. The source
  tree remains under upstream's authority.
- Variant translations. The project does not add custom examples,
  restructure the original material, or introduce personal
  commentary. Translations adhere closely to the original in both
  meaning and paragraph structure. Issues with the original text
  are addressed by submitting patches upstream rather than
  modifying the translation.
- Parallel translations for multiple kernel versions. The project
  tracks master HEAD exclusively, with rebases performed during
  each synchronization. Users requiring translations of older
  versions can check out an appropriate earlier commit.
- Bulk machine translation with manual post-editing. Machine
  translation may serve as a reference for terminology or
  difficult passages, but its output is not suitable for direct
  inclusion in pull requests. Reviewer effort to correct machine
  output typically exceeds the cost of manual translation.
- Contributor License Agreements. DCO is the governance model, in
  alignment with upstream kernel practice.

## Long-term outlook

A plausible outcome, assuming sustained project activity over a
period of several years:

- Between 20 and 50 core documents translated to a publishable
  standard, with coverage concentrated in `process/`, `admin-guide/`,
  and `core-api/`.
- A stable contributor base capable of operating without dependence
  on any single maintainer.
- A stable glossary that serves as a reference for other Vietnamese
  technical translation projects beyond the kernel.
- Evaluation of a patch series to LKML for inclusion of
  `Documentation/translations/vi_VN/` in the mainline kernel tree.
  This step requires sufficient content to demonstrate sustained
  project activity rather than a one-time contribution.

Upstreaming is not a required outcome. A public mirror that tracks
upstream and provides verified Vietnamese translations constitutes a
valuable result independent of upstream inclusion.
