#!/usr/bin/env Rscript

library(methods)
library(BBmisc)
library(devtools)
library(stringr)
library(checkmate)
library(ParamHelpers)
library(mlrMBO)
#load_all("/home/bischl/cos/mlrMBO")

extractField = function(lines, pattern, convert = as.character) {
  hit = which(str_detect(lines, pattern))
  assertInt(hit, lower = 1L, na.ok = FALSE)
  entry = str_trim(str_split(lines[hit], "=")[[1L]][2L])
  convert(entry)
}

cargs = commandArgs(TRUE)

path.optdir = cargs[1L]
path.parset = cargs[2L]
path.config = file.path(path.optdir, "config.cfg")
config = readLines(path.config)

message(collapse(config, "\n"))

# extract config of mbo run
number.of.jobs              = extractField(config, "number_of_jobs = ", as.integer)
number.of.concurrent.jobs   = extractField(config, "number_of_concurrent_jobs = ", as.integer)
number.cv.folds             = extractField(config, "number_cv_folds = ", as.integer)
handles.cv                  = extractField(config, "handles_cv = ", as.integer)

# go to dir of run
setwd(path.optdir)

# messagef("Run dir      : %s", path.optdir)
# messagef("Param set    : %s", path.parset)
# messagef("Run Config   : %s", path.config)

# read parset.R
source(path.parset)

# construct objective function in R
objfun = makeSingleObjectiveFunction(
  name = "HPOlib",
  fn = function(x) {
      params = removeMissingValues(x)
      params = paste("-", names(params), " \\'", as.character(params), "\\'", sep = "")
      s = system2("python", c("-m", "HPOlib.optimization_interceptor", "--params", params), stdout = TRUE, stderr = TRUE)
      pattern = "Result:"
      j = which(str_detect(s, pattern))
      assertInt(j, lower = 1L, na.ok = FALSE)
      as.numeric(str_split(s[j], ",| ")[[1L]][2L])
  },
  par.set = par.set,
  global.opt.value = -Inf
)

dimx = getParamNr(par.set, devectorize = TRUE)

# lets do this heuristic now, for autoweka this will not scale
init.design.points = dimx * 4L - 1
iters = number.of.jobs - init.design.points
design = rbind(generateDesign(init.design.points, par.set), generateDefaultDesign(par.set))
ctrl = makeMBOControl(y.name = "..y..")
ctrl = setMBOControlTermination(iters = iters, control = ctrl)
ctrl = setMBOControlInfill(ctrl, crit = "cb", crit.cb.lambda = 1L, 
  opt = "focussearch",
  opt.focussearch.points = 1000, 
  opt.focussearch.maxit = 5L, 
  opt.restarts = 3L,
  filter.proposed.points = FALSE)

learner = makeLearner("regr.randomForest", predict.type = "se")

# dirty hack: use values that are out of range to impute
cols = lapply(par.set$pars, function(p) {
  if (p$type %in% c("numeric", "integer"))
    imputeConstant(ifelse(p$upper < 0, ceiling(p$upper/2), ifelse(p$upper == 0, 1, p$upper*2)))
  else if (p$type %in% c("discrete"))
    imputeConstant("__miss__")
})
names(cols) = getParamIds(par.set)
learner = makeImputeWrapper(learner, cols = cols)

mbo(objfun, design = design, learner = learner, control = ctrl)

