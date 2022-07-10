sample=$1
indir=$2
FW=$indir/02.effective/$sample/$sample.R1.fq.gz
RV=$indir/02.effective/$sample/$sample.R2.fq.gz
MAP=/gpfs/ycga/project/fan/aeb98/00.database/GRCm39/STARindex
ANN=/gpfs/ycga/project/fan/aeb98/00.database/GRCm39/gencode.vM29.annotation.gtf
CONT=/gpfs/ycga/project/fan/aeb98/00.database/GRCm39/STARindex_nc
ID=/gpfs/ycga/project/fan/aeb98/00.database/barcodes-AB.xls
OUTPUT=$indir/03.stpipeline/$sample
mkdir -p $indir/03.stpipeline/$sample
TMP=$indir/03.stpipeline/$sample/tmp
mkdir -p $indir/03.stpipeline/$sample/tmp
EXP=$sample
st_pipeline_run.py \
  --output-folder $OUTPUT \
  --temp-folder $TMP \
  --umi-start-position 16 \
  --umi-end-position 26 \
  --ids $ID \
  --ref-map $MAP \
  --ref-annotation $ANN \
  --expName $EXP \
  --htseq-no-ambiguous \
  --verbose \
  --threads 16 \
  --log-file $OUTPUT/${EXP}_log.txt \
  --star-two-pass-mode \
  --no-clean-up \
  --contaminant-index $CONT \
  --disable-clipping \
  --min-length-qual-trimming 30 \
  $FW $RV
