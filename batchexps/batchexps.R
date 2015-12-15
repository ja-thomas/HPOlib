library(BatchExperiments)

unlink("HPOlib_benchmark-files", recursive = TRUE)

reg = makeExperimentRegistry("HPOlib_benchmark")

scenarios = list.dirs("benchmarks", recursive = FALSE, full.names = FALSE)

for (s in scenarios) {
  addProblem(reg, id = s, static = list(benchmark = s))
}

optimizers = c("smac", "mlrMBO")

addAlgorithm(reg, id = "optimizer-wrapper", function(static, optimizer) {
  setwd(file.path("benchmarks", static$benchmark))
  cmd1 = "/home/bisc"
  cmd = sprintf("HPOlib-run -o ../../optimizers/%s/%s", optimizer, optimizer)
  print(cmd)
  system(cmd)
})

ades = makeDesign("optimizer-wrapper", exhaustive = list(optimizer = optimizers))

addExperiments(reg, algo.designs = ades, repls = 1)


testJob(reg, 1)

