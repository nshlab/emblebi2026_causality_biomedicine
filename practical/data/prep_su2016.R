################################################################################
# Prepare a classroom extract of the Su et al. (2016) smoking/methylation data
################################################################################

# Run ONCE by the instructors, NOT on the course VM: it needs limma and readxl,
# which are not in the VM's renv.lock. Its output, `su2016_methylation.csv.gz`,
# is what participants load.
#
# Source data:
#   * normalized beta values, GEO GSE85210 (GSE85210_Matrix_processed.txt.gz)
#   * covariates and cell-type proportions, from
#     https://github.com/nhejazi/pub_biotmle_smmr/tree/main/application/data
#
# Mirrors the pre-processing and limma screening step of the biotmle
# application (Hejazi et al.), then keeps a random subset of the screened CpGs
# (plus a few well-known smoking CpGs) and an equal number of CpGs that did
# NOT pass the screen, so that the practical runs in minutes and multiple
# testing has something to do.
#
# Usage: Rscript prep_su2016.R <path/to/GSE85210_Matrix_processed.txt.gz> \
#          <path/to/se-smokers-metadata-for-phillipe.xlsx>

args <- commandArgs(trailingOnly = TRUE)
beta_path <- args[1]
meta_path <- args[2]
out_path <- "su2016_methylation.csv.gz"
n_screened <- 150
n_unscreened <- 150
set.seed(4512316)

# beta values: drop detection p-value columns, keep CpG x sample matrix
# (the file has a two-line header; sample names are on line one, alternating
# with "Detection Pval" columns, so betas are in columns 2, 4, 6, ...)
hdr <- strsplit(readLines(gzfile(beta_path), n = 1), "\t")[[1]]
betas <- data.table::fread(beta_path, skip = 2, header = FALSE,
                           data.table = FALSE)
beta_cols <- seq(2, ncol(betas), by = 2)
cpg_ids <- betas[[1]]
betas <- as.matrix(betas[, beta_cols])
dimnames(betas) <- list(cpg_ids, hdr[beta_cols])

# metadata, recoded numerically
meta <- as.data.frame(readxl::read_xlsx(meta_path))
meta <- data.frame(
  id = meta$Sample_Name1,
  smoker = meta$`Sample_Group Never=0 Ever=1`,
  sex = as.integer(meta$`sex M=1 F=2` == 2),       # 1 = female
  race = as.integer(meta$`race W=1, B=2` == 2),    # 1 = Black
  age = meta$age,
  meta[, c("CD8T", "CD4T", "NK", "Bcell", "Mono", "Gran")]
)

# align samples BY NAME (not by sort order)
stopifnot(setequal(colnames(betas), meta$id))
betas <- betas[, meta$id]
stopifnot(identical(colnames(betas), meta$id))

# M-values, dropping CpGs with missing or degenerate betas
betas <- betas[stats::complete.cases(betas), ]
betas <- pmin(pmax(betas, 1e-4), 1 - 1e-4)
mvals <- log2(betas / (1 - betas))

# limma screen, as in the published analysis (robust eBayes, Holm, 0.05)
design <- model.matrix(
  ~ smoker + sex + age + race + CD8T + CD4T + NK + Bcell + Mono + Gran,
  data = meta
)
fit <- limma::eBayes(limma::lmFit(mvals, design), robust = TRUE)
tt <- limma::topTable(fit, coef = "smoker", adjust.method = "holm",
                      number = Inf, sort.by = "p")
screened <- rownames(tt)[tt$adj.P.Val < 0.05]
message("CpGs measured: ", nrow(mvals), "; passing limma screen: ",
        length(screened))

# well-known smoking CpGs (AHRR, 2q37.1, F2RL3, GPR15), kept if screened
known <- intersect(c("cg05575921", "cg21566642", "cg03636183", "cg19859270"),
                   screened)
keep <- c(
  known,
  sample(setdiff(screened, known), n_screened - length(known)),
  sample(setdiff(rownames(mvals), screened), n_unscreened)
)

# wide file: one row per person, covariates then one column per CpG
out <- cbind(meta, t(mvals[keep, ]))
data.table::fwrite(out, out_path)

# instructor-only key: which CpGs passed the screen in the full data
data.table::fwrite(
  data.frame(cpg = keep, screened = keep %in% screened),
  "su2016_cpg_key.csv"
)
message("wrote ", out_path, ": ", nrow(out), " people x ", length(keep),
        " CpGs (of ", nrow(mvals), " measured)")
