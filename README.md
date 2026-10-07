# Causality in Biomedicine (EMBL-EBI 2026) — Day 3 materials

Practical session for *Biomarker discovery from expression data* (Day 3,
14:45–16:00) of the EMBO Practical Course
[*Causality in Biomedicine* (2026)](https://www.ebi.ac.uk/training/events/causality-in-biomedicine-2026/),
with Nima Hejazi and Sjoerd Beentjes. It renders to a Quarto book.

## Layout

```
_quarto.yml            book config (instructor build, with solutions)
_quarto-students.yml   participant build profile (solutions hidden)
index.qmd              welcome, session plan, setup
chapters/              Part 1 (biotmle.qmd), Part 2 (sve.qmd)
practical/R/           helper functions participants source
practical/data/        classroom data extract and the script that builds it
refs.bib               bibliography
renv.lock              the course VM's R environment
resources/             reference inputs — GITIGNORED, not part of the build
```

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) ≥ 1.5 (developed on 1.10)
- R 4.5.2 (as on the course VM) with [`renv`](https://rstudio.github.io/renv/)
- A LaTeX install is **not** required for the website (HTML output).

## Set up the R environment

```bash
# From the repo root, in R:
Rscript -e 'renv::restore()'
```

`renv.lock` is the EBI course VM's environment: participant-facing code may
only use packages listed there. Don't `renv::snapshot()` new packages into it.

## Build

Live preview while writing (rebuilds on save, opens a browser):

```bash
quarto preview
```

Render the instructor version (with solutions) to `_site/`:

```bash
quarto render
```

Render the participant version (solutions hidden) to `_site_students/`:

```bash
quarto render --profile students
```

Both builds produce HTML and a PDF (via LuaLaTeX). PDF only:
`quarto render --profile students --to pdf`.

## Deployment

Pushing to `main` runs `.github/workflows/publish.yml`, which renders the
**instructor** build (with solutions) from the committed `_freeze/` cache (no
R on the runner) and deploys it to GitHub Pages. After changing any R code,
re-render locally and commit `_freeze/`. To hide the solutions again, switch
the workflow to `quarto render --profile students` and `path: _site_students`.

## Rebuilding the classroom data

`practical/data/su2016_methylation.csv.gz` is derived from GEO GSE85210 and the
metadata in [nhejazi/pub_biotmle_smmr](https://github.com/nhejazi/pub_biotmle_smmr/tree/main/application/data).
Rebuilding needs `limma`, which is not on the course VM, so run it with an R
that has Bioconductor, from `practical/data/`:

```bash
Rscript --vanilla prep_su2016.R GSE85210_Matrix_processed.txt.gz se-smokers-metadata-for-phillipe.xlsx
```

`_site/`, `_site_students/`, `.quarto/`, and per-document `*_files/` caches are build artifacts and
are gitignored — never commit them.

## Reference material (`resources/`)

`resources/` holds past workshop materials and grant text used **only to inform**
these materials. It is gitignored and never published. Read from it to derive
content; write the result, in original wording, into the tracked `.qmd` files.
Don't commit anything from `resources/` or link to its paths. See `CLAUDE.md`.

## Publishing

Not wired up yet. When ready, the usual path is GitHub Pages via
`quarto publish gh-pages`, or hosting the rendered `_site/` wherever EMBL-EBI
prefers. Decide before the course and add the target here.
