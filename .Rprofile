options(renv.config.pak.enabled = TRUE)
#options(renv.config.auto.snapshot = TRUE)
# sl3 and tmle3 match renv.lock (same commits) but differ in recorded git refs
# (HEAD vs master); skip renv's startup sync check rather than edit the VM's
# lockfile. renv::status() still reports the details on request.
options(renv.config.synchronized.check = FALSE)
source("renv/activate.R")
