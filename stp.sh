#!/bin/bash
#SBATCH --partition=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alev.baysoy@yale.edu
#SBATCH --job-name=st-pipeline
#SBATCH --ntasks=1 --cpus-per-task=16
#SBATCH --mem-per-cpu=4g 
#SBATCH --time=120:00:00

sh 2-stpipeline.sh SP0222 /gpfs/ycga/project/fan/aeb98/01.DBIT
