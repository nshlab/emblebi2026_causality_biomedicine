# CLAUDE.md

Guidance for Claude when working in this repository.

## What this is

Course materials for **Nima Hejazi's** contributions to the EMBL-EBI short
course *Causality in Biomedicine* (2026):
<https://www.ebi.ac.uk/training/events/causality-in-biomedicine-2026/>

Nima presents on **Day 3** (~4 hours total):

| Slot | Content | This repo |
|------|---------|-----------|
| Keynote (~45 min) | *Mediation analysis in molecular biology* | `keynote/` — reveal.js slides |
| Networking lunch | — | — |
| Session (~2 h) | *Biomarker discovery from expression data* | `notes/` — ~45 min lecture |
| ↳ Practical (~1.25 h) | Hands-on, framed via causal mediation | `practical/` — R + Bioconductor |

The through-line: **biomarker discovery framed as causal mediation** — mediators
of a treatment/exposure effect on a molecular or clinical outcome, using
expression (RNA-seq/microarray) data.

Output is a **single Quarto website**. The keynote is a reveal.js `.qmd` built
as part of that same site.

## Structure

```
_quarto.yml        website config (navbar, theme, render list)
index.qmd          landing page: overview, schedule, links to each part
keynote/           reveal.js keynote (format: revealjs)
notes/             lecture notes on biomarker discovery + causal mediation
practical/         hands-on session (R + Bioconductor); data/ or a download script
references.bib     shared bibliography
renv.lock          pinned R environment (tracked; library is gitignored)
resources/         GITIGNORED reference material — see rule below
```

## The `resources/` rule (important)

`resources/` holds **past workshop materials and grants** used to *inform* new
material. It is **gitignored**.

- **Read** from it freely to derive and adapt content.
- **Never `git add`** it, reference its paths in committed files, or paste its
  contents verbatim into published pages. Grant text especially is not for
  publication — adapt and rewrite, don't copy.
- If a draft needs something from `resources/`, restate it in the author's own
  words in the tracked `.qmd`; the source stays in `resources/`.

## Stack & conventions

- **R + Bioconductor** for the practical: `SummarizedExperiment` /
  `SingleCellExperiment` for containers, `limma`/`edgeR`/`DESeq2` for the
  expression-analysis baseline, and Nima's causal-mediation tooling
  (`medoutcon` and related) for the causal layer.
- Reproducibility via **renv** — `renv.lock` is tracked; run `renv::restore()`.
- Prefer small, downloadable, or packaged example data over committing large
  matrices. A script under `practical/data/` that fetches/derives the dataset
  beats a checked-in `.rds` when feasible.
- Notes and slides share `references.bib`; cite with `[@key]`.
- Author voice is Nima's (first person, biostatistician). Precise but
  audience-accessible — this is a mixed biomedical/computational audience, not
  a stats seminar.

## Build

See `README.md`. In short: `quarto preview` while writing, `quarto render` to
build the whole site into `_site/`.

## Working norms

- This is a **teaching/writing** repo, not a software package. The deliverable
  is clear prose, correct math, and runnable example code — not abstraction.
- Keep code chunks in the practical **runnable end to end** on the pinned
  environment. A broken chunk is a broken lesson.
- When unsure about scope, timing, or emphasis for a section, ask — the minute
  budgets above are tight and drive what goes in.
