import pickle as pk
import glob as glob
import pandas as pd

paths = ["hpdbnet/convex/", "hpdbnet/mrbi/" ,"benchmarks/branin/", "benchmarks/camelback/", "benchmarks/har6/", "benchmarks/lda_on_grid/", "benchmarks/logreg_on_grid/", "benchmarks/michalewicz/", "benchmarks/svm_on_grid/", "hpnnet/cv_convex/", "hpnnet/nocv_convex/", "hpnnet/cv_mrbi/", "hpnnet/nocv_mrbi/"]

methods = ["mlrMBO"]

data = {'result':[], 'runtime':[], 'optimizer':[], 'problem':[]}


for p in paths:
	for m in methods:
		files = glob.glob(p + m + "_*")
		for f in files:
			print f
			pfile = glob.glob(f + "/*.pkl")
			with open(pfile[0], "r") as input_file:
				res = pk.load(input_file)
				data["result"].append(min([r["result"] for r in res["trials"]]))
				data["runtime"].append(res["endtime"][0] - res["starttime"][0])
				data["optimizer"].append(m)
				data["problem"].append(p)

pd.DataFrame(data).to_csv("results/results_new.csv", sep = ",", encoding = "utf-8", index = False)

				
			 
	
	
