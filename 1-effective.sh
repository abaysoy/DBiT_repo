#DO NOT CHANGE THIS CODE, only part that needs to change is the sampleid


#!/bin/bash
#SBATCH --partition=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alev.baysoy@yale.edu
#SBATCH --job-name=test
#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --mem-per-cpu=4g 
#SBATCH --time=120:00:00
module load Perl/5.28.0-GCCcore-7.3.0
export PERL5LIB=/gpfs/ycga/project/fan/aeb98/00.software/PerlIO-gzip-0.20/mybuild/lib/perl5/site_perl/5.28.0/x86_64-linux-thread-multi/:$PERL5LIB
project_dir=/gpfs/ycga/project/fan/aeb98/01.DBIT
#CHANGE THE BELOW EACH TIME YOU RUN A NEW SAMPLE 
sampleid=CROP_gex_0622
gzip -d $project_dir/01.rawdata/$sampleid/*1.fq.gz
gzip -d $project_dir/01.rawdata/$sampleid/*2.fq.gz
gzip $project_dir/01.rawdata/$sampleid/*1.fq
gzip $project_dir/01.rawdata/$sampleid/*2.fq
perl /gpfs/ycga/project/fan/aeb98/00.bin/1-effective.pl -indir $project_dir/01.rawdata -outdir $project_dir/02.effective -insertsize $sampleid
