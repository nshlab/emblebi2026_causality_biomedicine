# CLAUDE.md

Guidance for Claude when working in this repository.

## What this is

Course materials for **Nima Hejazi's** contributions to the EMBL-EBI short
course *Causality in Biomedicine* (2026):
<https://www.ebi.ac.uk/training/events/causality-in-biomedicine-2026/>

Nima presents on **Day 3** (Wed 7 Oct 2026). The keynote (12:00, based on
the 2023 `txshift`/SVE talk) and the lecture (14:00, based on the 2024
`biotmle` talk) reuse existing slide decks and are **not** in this repo. This
repo is the **practical** (14:45–16:00, 75 min), led by Nima with Sjoerd
Beentjes circulating: participants work through exercises, then Nima goes over
the answers.

The practical has two parts, each reinforcing one lecture:

1. `chapters/biotmle.qmd` — rebuild `biotmle` by hand (one-step ATE per CpG
   with SuperLearner, moderated EIF variance, multiple testing) on the Su et
   al. (2016) smoking/methylation data.
2. `chapters/sve.qmd` — stochastic-interventional vaccine efficacy, a
   population mean under a modified treatment policy (MTP; an additive shift
   of titers), with `lmtp` (reweighted, not augmented, for the two-phase
   design) on a simulated case-cohort trial. Call the shift an MTP, not a
   "shift estimand".

Through-line: each causal parameter **reduces to a linear-model coefficient**
when that model is correct (ATE = β₁; ψ_δ − ψ₀ = β₁δ, with SVE_δ = 1 − ψ_δ / P(Y = 1 | A = 0)) — accessible but
brittle. Exercises mix pen-and-paper and (mostly) coding.

By Day 3, participants have covered SCMs, potential outcomes, identification,
regression adjustment, uncertainty quantification, model misspecification and
targeted learning (see the course programme). Don't re-teach those.

## Structure

```
_quarto.yml            Quarto book config (instructor build, with solutions)
_quarto-students.yml   `--profile students`: hides solutions + view-source
index.qmd              welcome, session plan, VM setup
chapters/              biotmle.qmd (Part 1), sve.qmd (Part 2)
practical/R/           helpers sourced by participants (moderate.R, sim_vaccine_trial.R)
practical/data/        su2016_methylation.csv.gz (+ instructor key, prep script)
refs.bib, headers/, style.scss   bibliography, MathJax macros, theme (from
                       ../causal_mediation_workshops)
renv.lock              the EBI course VM's environment — authoritative
resources/             GITIGNORED reference material — see rule below
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

- **Only packages in `renv.lock` exist on the course VM** (R 4.5.2). It has no
  Bioconductor: no `biotmle`, `limma`, `SummarizedExperiment`; no `txshift`.
  Available and used: `SuperLearner`, `lmtp`, `ggplot2` (also `sl3`, `tmle3`,
  `hal9001`, `medoutcon`, `medshift`). Check the lockfile before using any
  package in participant-facing code.
- `practical/data/prep_su2016.R` is instructor-only (needs `limma`, run under
  a separate R with Bioconductor); participants only `read.csv()` its output.
- Exercises: skeleton chunk with `___` and `#| eval: false`, followed by a
  solution inside `::: {.content-hidden when-profile="students"}` wrapping a
  collapsed `callout-tip` titled "Solution". Solution chunks are evaluated,
  and later exercises depend on their objects.
- Mark pen-and-paper exercises ✏️ and coding exercises 💻.
- Cite with `[@key]` from `refs.bib`.

## Build

See `README.md`. `quarto render` → `_site/` (instructor, with solutions);
`quarto render --profile students` → `_site_students/`. Full render ≈ 1.5 min.

## Working norms

- This is a **teaching/writing** repo, not a software package. The deliverable
  is clear prose, correct math, and runnable example code — not abstraction.
- Keep code chunks in the practical **runnable end to end** on the pinned
  environment. A broken chunk is a broken lesson.
- When unsure about scope, timing, or emphasis for a section, ask — the minute
  budgets above are tight and drive what goes in.
