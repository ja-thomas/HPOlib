#first the easy benchmarks
scenarios = list.dirs("../benchmarks", recursive = FALSE, full.names = FALSE)[1]

#now the ugly ones
#scenarios2 = c(paste0("../hpdbnet/", c("convex", "mrbi")), paste0("../hpnnet/", c("cv_convex", "cv_mrbi", "nocv_convex", "nocv_mrbi")))

#scenarios = c(scenarios, scenarios2)

#optimizers = c("mlrMBO/mlrMBO", "mlrMBO-rf/mlrMBO", "smac/smac_2_08_00-master",
#  "spearmint/spearmint_april2013", "tpe/hyperopt_august2013")

optimizers = c("mlrMBO/mlrMBO", "mlrMBO-rf/mlrMBO")

for(k in 1:10) {
  for(i in seq_along(scenarios)) {
    s = scenarios[i]
    
    problem = strsplit(s, "/")[[1]]
    problem = problem[length(problem)]
    
    for(j in seq_along(optimizers)) {
      o = optimizers[j]
      opt = strsplit(o, "/")[[1]][1]
      if ((o == "mlrMBO-rf/mlrMBO" & (grepl("hpdbnet", s) | grepl("hpnnet", s))) | (o == "mlrMBO/mlrMBO" & !(grepl("hpdbnet", s) | grepl("hpnnet", s)))){
        cmd = paste0('cd ../', file.path('benchmarks', s), ' && HPOlib-run -o ../../optimizers/', o, " -s ", k)
        
        if (grepl("hpdbnet", s)) {
          deamonPath = paste0('--HPOLIB:function "daemon_whisperer.py --socket /tmp/',k,".",i, ".", j ,'hpdbnet_', problem, '_RandomForest --data ../models/ENCODED_hpdbnet_', problem, '_all_RandomForest --pcs ../../smac_2_06_01-dev/nips2011_dbn.pcs" --HPOLIB:function_teardown "daemonize_benchmark.py --socket /tmp/',k,".",i, ".", j, 'hpdbnet_', problem, '_RandomForest --stop --pcs ../smac_2_06_01-dev/nips2011_dbn.pcs" --HPOLIB:function_setup "daemonize_benchmark.py --pcs ../smac_2_06_01-dev/nips2011_dbn.pcs --socket /tmp/',k,".",i, ".", j, 'hpdbnet_', problem, '_RandomForest --surrogateData models/ENCODED_hpdbnet_', problem, '_all_RandomForest"')
          cmd = paste(cmd, deamonPath)
        }
        
        if (grepl("hpnnet", s)) {
          deamonPath = paste0('--HPOLIB:function "daemon_whisperer.py --socket /tmp/',k,".",i, ".", j ,'hpnnet_', problem, '_RandomForest --data ../models/ENCODED_hpnnet_', problem, '_all_RandomForest --pcs ../../smac_2_06_01-dev/nips2011.pcs" --HPOLIB:function_teardown "daemonize_benchmark.py --socket /tmp/',k,".",i, ".", j, 'hpnnet_', problem, '_RandomForest --stop --pcs ../smac_2_06_01-dev/nips2011.pcs" --HPOLIB:function_setup "daemonize_benchmark.py --pcs ../smac_2_06_01-dev/nips2011.pcs --socket /tmp/',k,".",i, ".", j, 'hpnnet_', problem, '_RandomForest --surrogateData models/ENCODED_hpnnet_', problem, '_all_RandomForest"')
          
          cmd = paste(cmd, deamonPath)
        }
        
        cmd = paste0(cmd, " > ", k, ".", problem, ".", opt, ".out")
        cmd = paste0(cmd, " 2> ", k, ".", problem, ".", opt, ".err")
        cat(cmd)
        cat("\n")
      }
    }
  }
}
