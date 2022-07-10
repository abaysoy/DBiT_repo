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
* Unzup annotation file and concatenate them together. Delete the original separate files after.    
* X, Y, and M represent the extra chromosomes in the files , you may need to change these names 
```
for i in {1..22} X Y M; do gzip -d chr$i.fa.gz;done
for i in {1..22} X Y M; do cat chr$i.fa; done >> hg38.fa
for i in {1..22} X Y M; do rm chr$i.fa;done
cut -f1  Homo_sapiens.GRCh38.105.gtf | uniq
       cut -f1 gencode.v39.annotation.gtf | uniq
       grep '>chr' hg38.fa
       ```


