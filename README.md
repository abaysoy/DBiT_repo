# DBiT Pipeline 

## Prior to Data Acquisition
1. Experiments are done on <10 mm thick tissue samples, 50x50 or 100x100 barcodes 
2. Sequences are extracted using the Illumina kit and sequenced by Novogene
## Setting up the environment 
* Set up Environment for raw data processing
* see https://github.com/jfnavarro/st_pipeline for ST_Pipeline documentation
*For setting up the first time: 
```
module load miniconda
conda create -n st-pipeline python=3.7
conda activate st-pipeline
conda install PySam
conda install Numpy
conda install Cython
pip install taggd 
pip install stpipeline
```
*Subsequent environment set-up:
```
module load miniconda
conda activate st-pipeline
```
* Test the installment
```
st_pipeline_run.py -h
```
## Set up Perl environment on HPC (again, first time only if Perl package is missing)
```
wget https://cpan.metacpan.org/authors/id/N/NW/NWCLARK/PerlIO-gzip-0.20.tar.gz
module load Perl/5.28.0-GCCcore-7.3.0
tar -zxvf PerlIO-gzip-0.20.tar.gz 
cd PerlIO-gzip-0.20/
mkdir mybuild
perl Makefile.PL PREFIX=/gpfs/ysm/project/fan/sb2723/01.Spatial_hCortex/00.bin/PerlIO-gzip-0.20/mybuild
make
make install
```
* Install SVG environment
```
wget https://cpan.metacpan.org/authors/id/M/MA/MANWAR/SVG-2.86.tar.gz
tar -zxvf SVG-2.86.tar.gz 
cd SVG-2.86/
mkdir mybuild
perl Makefile.PL PREFIX=/gpfs/ysm/project/fan/sb2723/01.Spatial_hCortex/00.bin/SVG-2.86/mybuild
make
make install
```
*Load genome references from gencode - the following example is for human data. You only need to change this if there is a new update
```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_39/gencode.v39.annotation.gtf.gz
wget http://ftp.ensembl.org/pub/release-105/gtf/homo_sapiens/Homo_sapiens.GRCh38.105.gtf.gz
wget http://ftp.ensembl.org/pub/release-105/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz #noncoding rna
```
*Install STAR and SamTools to establish the reference database, put in the database folder 
```
module load miniconda
conda activate st-pipeline
conda install -c bioconda star
conda install -c bioconda samtools openssl=1.0
st_pipeline_run.py -v
rsync -avzP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/chromosomes/ .
```
* remove all unknown and random chromosome files ChrUn.xxx.fa.gz
```   
rm chr*_*.fa.gz
```
* Unzip annotation file and concatenate them together. Delete the original separate files after.    
* X, Y, and M represent the extra chromosomes in the files , you may need to change these names 
```
for i in {1..22} X Y M; do gzip -d chr$i.fa.gz;done
for i in {1..22} X Y M; do cat chr$i.fa; done >> hg38.fa
for i in {1..22} X Y M; do rm chr$i.fa;done
cut -f1  Homo_sapiens.GRCh38.105.gtf | uniq
cut -f1 gencode.v39.annotation.gtf | uniq
grep '>chr' hg38.fa
```
* Make directory of STARindex and STARindex_nc (noncoding) 
* The following in the _starindex.sh_ and _starindex_nc.sh_ needed to be changed, and the sbatch both files, remember to request for the interactive nodes for the job
* Make a directory of the STARindex and set it as the genomeDir
```
--genomeDir /gpfs/ysm/project/fan/aeb98/00.database/hg38/STARindex
```
* The genome fasta file is the one we combined inw the last step
```
--genomeFastaFiles /gpfs/ysm/project/fan/sb2723/00.database/hg38/hg38.fa
```
* The annotation file should coordinate with the genome fasta file (the chromosome name should be chr* or numbers/X/Y only 
```
--sjdbGTFfile /gpfs/ysm/project/fan/aeb98/00.database/hg38/gencode.v39.annotation.gtf
```
* The overhang line denotes the sequencing lenght, we are using 150 (so set it to 140, one less).
* The limit of the genome generate RAM should be adjusted by the instruction (double confirm with others)
```
limitGenomeGenerateRAM 50000000000
```
* change the directory to nc folder and the fasta files should also be changed 
```
--genomeDir /gpfs/ysm/project/fan/sb2723/00.database/hg38/StarIndex_nc
--genomeFastaFiles /gpfs/ysm/project/fan/sb2723/00.database/hg38/Homo_sapiens.GRCh38.ncrna.fa
```
* For mouse genome reference (whole workflow is doable)
* current chromosome sequence source: http://hgdownload.soe.ucsc.edu/goldenPath/mm39/chromosomes/
* Current annotations are from: https://useast.ensembl.org/Mus_musculus/Info/Index
```
rsync -avzP rsync://hgdownload.cse.ucsc.edu/goldenPath/mm39/chromosomes/ .
rm chr*_*.fa.gz
for i in {1..19} X Y M; do gzip -d chr$i.fa.gz;done
for i in {1..19} X Y M; do cat chr$i.fa; done >> mm39.fa
for i in {1..19} X Y M; do rm chr$i.fa;done
#annotations: 
wget http://ftp.ensembl.org/pub/release-105/fasta/mus_musculus/ncrna/Mus_musculus.GRCm39.ncrna.fa.gz
wget http://ftp.ensembl.org/pub/release-105/gtf/mus_musculus/Mus_musculus.GRCm39.105.gtf.gz
gzip -d Mus_musculus.GRCm39.105.gtf.gz
gzip -d Mus_musculus.GRCm39.ncrna.fa.gz 
cut -f1 Mus_musculus.GRCm39.105.gtf | uniq
cut -f1 Mus_musculus.GRCm39.ncrna.fa | uniq
       
#The following are the useful part:
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M28/gencode.vM28.annotation.gtf.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M28/gencode.vM28.long_noncoding_RNAs.gtf.gz
gzip -d gencode.vM28.annotation.gtf.gz 
gzip -d gencode.vM28.long_noncoding_RNAs.gtf.gz 

cd /gpfs/ysm/project/fan/aeb98/00.database/mm39
       
mkdir STARindex_nc
mkdir STARindex
        
module load miniconda
conda activate st-pipeline
srun --pty -p interactive -c 4 --mem=16g bash
        
#change the pathway inside the file
sh starindex.sh
sh starindex_nc.sh
```

## HPC Data Processsing
* use wget to download data from novogene - check the library QC report and put it into excel file documenting this information for all samples
* Batch download the data to the HPC folder 
* Make a new project folder within the 00.rawdata folder
* will need to unzip and rezip the data (I already have this written into the 01.effective.sh script
1. Filter the raw data and rearrange the read format to be compativle with ST pipeline using 1-effective.pl perl script, the barcode file should be used for this script and in an accessible folder. 
2. Should be able to 

