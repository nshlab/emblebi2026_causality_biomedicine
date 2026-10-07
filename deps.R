# Declares packages in renv.lock (the EBI course VM environment) that the
# materials do not load directly: learners named only as strings (e.g.,
# "SL.glmnet", "SL.earth"), related causal inference packages
# (medoutcon, medshift, sl3, tmle3, hal9001), and tools on the VM. renv scans
# this file, so renv::status() treats them as used. (Their own dependencies
# follow automatically.) Never run: the block exists only for renv.
if (FALSE) {
  library(bbotk)
  library(crumble)
  library(downlit)
  library(earth)
  library(fastDummies)
  library(gitcreds)
  library(hal9001)
  library(languageserver)
  library(lobstr)
  library(magick)
  library(medoutcon)
  library(medshift)
  library(mma)
  library(pak)
  library(pdftools)
  library(quarto)
  library(ranger)
  library(remotes)
  library(sessioninfo)
  library(skimr)
  library(speedglm)
  library(svglite)
}
