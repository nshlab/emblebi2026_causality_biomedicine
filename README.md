# Causality in Biomedicine (EMBL-EBI 2026) — Day 3 materials

Materials for Nima Hejazi's Day 3 contributions to the EMBL-EBI short course
[*Causality in Biomedicine* (2026)](https://www.ebi.ac.uk/training/events/causality-in-biomedicine-2026/):
a keynote on **mediation analysis in molecular biology** and a session on
**biomarker discovery from expression data** (lecture + hands-on practical),
framed throughout as causal mediation.

Everything renders to a single **Quarto website**.

## Layout

```
_quarto.yml        website config
index.qmd          landing page: schedule + links
keynote/           reveal.js keynote
notes/             biomarker-discovery lecture notes
practical/         hands-on R + Bioconductor session
references.bib     shared bibliography
renv.lock          pinned R environment
resources/         reference inputs — GITIGNORED, not part of the build
```

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) ≥ 1.5 (developed on 1.10)
- R ≥ 4.4 with [`renv`](https://rstudio.github.io/renv/)
- A LaTeX install is **not** required for the website (HTML output).

## Set up the R environment

```bash
# From the repo root, in R:
Rscript -e 'renv::restore()'
```

`renv.lock` pins every package (Bioconductor included) so the practical's code
chunks run identically for authors and participants. After adding a package,
`renv::snapshot()` and commit the updated lock.

## Build

Live preview while writing (rebuilds on save, opens a browser):

```bash
quarto preview
```

Render the whole site to `_site/`:

```bash
quarto render
```

Render or preview a single file while iterating:

```bash
quarto preview keynote/mediation-molecular-biology.qmd
quarto render notes/biomarker-discovery.qmd
```

`_site/`, `.quarto/`, and per-document `*_files/` caches are build artifacts and
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
