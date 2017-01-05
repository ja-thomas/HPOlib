library(batchtools)
setwd("~/Projekte/HPOlib/")
OVERWRITE = TRUE

REPS = 10

if (OVERWRITE)
  unlink("HPOlib_benchmark", recursive = TRUE)

reg = makeExperimentRegistry("HPOlib_benchmark")


#first the easy benchmarks
scenarios = list.dirs("benchmarks", recursive = FALSE, full.names = FALSE)

#now the ugly ones
scenarios2 = c(paste0("../hpdbnet/", c("convex", "mrbi")), paste0("../hpnnet/", c("cv_convex", "cv_mrbi", "nocv_convex", "nocv_mrbi")))

scenarios = c(scenarios, scenarios2)

for (s in scenarios) {
  name = gsub("/", "", gsub("..", "", s, fixed = TRUE), fixed = TRUE)
  addProblem(name = name, data = list(benchmark = s))
}

optimizers = c("mlrMBO/mlrMBO", "mlrMBO-rf/mlrMBO", "smac/smac_2_08_00-master",
  "spearmint/spearmint_april2013", "tpe/hyperopt_august2013")

addAlgorithm(name = "optimizer-wrapper", fun = function(job, data, instance, optimizer, ... ) {
  system("source virtualHPOlib/bin/activate")
  setwd(file.path("benchmarks", instance$benchmark))
  cmd = sprintf("HPOlib-run -o ../../optimizers/%s", optimizer)
  
  # if (grepl("hpdbnet", instance$benchmark)) {
  #   
  #   problem = strsplit(instance$benchmark, "/")[[1]]
  #   problem = problem[length(problem)]
  #   
  #   random = as.character(abs(rnorm(1)))
  #   
  #   deamonPath = paste0('--HPOLIB:function "daemon_whisperer.py --socket /tmp/',random ,'hpdbnet_', problem, '_RandomForest --data ../models/ENCODED_hpdbnet_', problem, '_all_RandomForest --pcs ../../smac_2_06_01-dev/nips2011_dbn.pcs" --HPOLIB:function_teardown "daemonize_benchmark.py --socket /tmp/',random, 'hpdbnet_', problem, '_RandomForest --stop --pcs ../smac_2_06_01-dev/nips2011_dbn.pcs" --HPOLIB:function_setup "daemonize_benchmark.py --pcs ../smac_2_06_01-dev/nips2011_dbn.pcs --socket /tmp/', random, 'hpdbnet_', problem, '_RandomForest --surrogateData models/ENCODED_hpdbnet_', problem, '_all_RandomForest"')
  #   
  #   cmd = paste(cmd, deamonPath)
  # }
  
  print(cmd)
  system(cmd)
})


addExperiments(algo.designs = list("optimizer-wrapper" = data.frame(optimizer = optimizers, stringsAsFactors = FALSE)),
  repls = REPS)



