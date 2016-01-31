par.set = makeParamSet(
  makeIntegerParam("lrate", lower = 0, upper = 10),
  makeIntegerParam("l2_reg", lower = 0, upper = 10),
  makeIntegerParam("batchsize", lower = 0, upper = 7),
  makeIntegerParam("n_epochs", lower = 0, upper = 9)
)
