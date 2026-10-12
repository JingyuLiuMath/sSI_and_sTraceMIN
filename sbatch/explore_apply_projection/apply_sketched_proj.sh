#!/bin/bash

#SBATCH --job-name=apply_sketched_proj
#SBATCH --output=apply_sketched_proj_%j.out
#SBATCH --error=apply_sketched_proj_%j.err
#SBATCH --nodelist=bigMem1
#SBATCH --exclusive
#SBATCH --time=01:00:00

module unload MATLAB
module load MATLAB/R2026a || exit $?
matlab -batch "cd('/home/jyliu/sEVP'); setuppath; cd('experiments/explore_apply_projection'); exp_apply_sketched_proj;"
