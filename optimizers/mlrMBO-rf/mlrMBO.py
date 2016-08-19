import glob
import logging
import os
import re
import subprocess
import sys

import numpy as np

import HPOlib.wrapping_util as wrapping_util


logger = logging.getLogger("HPOlib.mlrMBO")


__authors__ = ["Katharina Eggensperger", "Matthias Feurer"]
__contact__ = "automl.org"

version_info = ["mlrMBO ==> v1.0"]

def check_dependencies():
  pass

def build_mlrmbo_call(config, options, optimizer_dir, parent_space):
    thispath = os.path.dirname(os.path.realpath(__file__))
    call = 'Rscript ' + os.path.join(thispath, config.get('mlrMBO', 'path_to_optimizer'), 'mlrMBO.R')
    call = ' '.join([call, optimizer_dir, parent_space])
    # call = os.path.join(config.get('mlrMBO', 'path_to_optimizer'), 'mlrMBO.R')
    return call

def main(config, options, experiment_dir, experiment_directory_prefix, **kwargs):
    # config:           Loaded .cfg file
    # options:          Options containing seed, restore_dir, 
    # experiment_dir:   Experiment directory/Benchmark_directory
    # **kwargs:         Nothing so far
    time_string = wrapping_util.get_time_string()

    optimizer_str = os.path.splitext(os.path.basename(__file__))[0]

    # Find experiment directory
    optimizer_dir = os.path.join(experiment_dir,
                                 experiment_directory_prefix
                                 + optimizer_str + "_" +
                                 str(options.seed) + "_" + time_string)

    # Set up experiment directory
    if not os.path.exists(optimizer_dir):
        os.mkdir(optimizer_dir)
    
    parent_space = os.path.join(experiment_dir, optimizer_str, "parset.R")
    if not os.path.exists(parent_space):
      raise Exception("mlrMBO search space not found. Searched at %s." % (parent_space))
    
    cmd = build_mlrmbo_call(config, options, optimizer_dir, parent_space)
        
    logger.info("### INFORMATION ##############################################################################################")
    logger.info("# You're running %70s                      #" % config.get('mlrMBO', 'path_to_optimizer'))
    logger.info("# Parset file    %70s                      #" % parent_space)
    logger.info("##############################################################################################################")
    return cmd, optimizer_dir
