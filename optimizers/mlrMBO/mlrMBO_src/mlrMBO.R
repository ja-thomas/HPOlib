#!/usr/bin/env Rscript

library(methods)
library(BBmisc)
library(devtools)
library(stringr)
library(checkmate)
library(ParamHelpers)
load_all("/home/bischl/cos/mlrMBO")

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


# construct objective function in R
objfun = function(x) {
  params = paste("-", names(x), " \\'", as.character(x), "\\'", sep = "")
  s = system2("python", c("../../../HPOlib/cv.py", params), stdout = TRUE, stderr = TRUE)
  pattern = " Result:"
  j = which(str_detect(s, pattern))
  assertInt(j, lower = 1L, na.ok = FALSE)
  as.numeric(str_trim(str_split(s[j], pattern)[[1L]][2L]))
}


# read parset.R
source(path.parset)

dimx = getParamNr(par.set, devectorize = TRUE)

# lets do this heuristic now, for autoweka this will not scale
init.design.points = dimx * 4L
iters = number.of.jobs - init.design.points
ctrl = makeMBOControl(init.design.points = init.design.points, iters = iters, y.name = "..y..")
ctrl = setMBOControlInfill(ctrl, crit = "ei", opt = "focussearch",
  opt.focussearch.points = 1000, opt.focussearch.maxit = 3L, opt.restarts = 3L)

learner = makeLearner("regr.km", predict.type = "se", nugget.estim = TRUE)

mbo(objfun, learner = learner, par.set = par.set, control = ctrl)

