#!/bin/bash
#SBATCH --partition=amilan
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aawe2235@colorado.edu
#SBATCH --job-name=Missingness_tests
#SBATCH --output Missingness_stats.txt

module purge
module load anaconda
module load perl
conda activate ipyrad

cd /scratch/alpine/aawe2235/Lasthenia_genomics/RADseqII/RAWseq/Lane1/Lane1_Run2RawUnfiltered/

create first overall project
ipyrad -n Lasthenia_L1R2 -f 

#set necessary paths for basic run, where our raw fastqs and barcodes are, set output to return ALL file types, set restriction overhang to Sfb1's overhang
sed -i '/\[2] /c\/scratch/alpine/aawe2235/Lasthenia_genomics/RADseqII/RAWseq/Lane1/Lane1_Run2RawUnfiltered/raw/014504_lane1_NoIndex_run381_L001_R1_001.fastq ## [2]' params-Lasthenia_L1R2.txt
sed -i '/\[3] /c\/scratch/alpine/aawe2235/Lasthenia_genomics/RADseqII/RAWseq/Lane1/Lane1_Run2RawUnfiltered/barcodes/ipy_barcodes.txt ## [3]' params-Lasthenia_L1R2.txt
sed -i '/\[27] /c\* ## [27]' params-Lasthenia_L1R2.txt
sed -i '/\[8] /c\ACGTCC, ## [8]' params-Lasthenia_L1R2.txt
sed -i '/\[15] /c\1 ## [15]' params-Lasthenia_L1R2.txt

ipyrad -b Lasthenia_L1R1_miss - DL4_1 DL4_2

ipyrad -p params-Lasthenia_L1R2_miss.txt -s 12 -c ${SLURM_NTASKS} -f

#create branches for one mismatch and two mismatches with barcode 
ipyrad -p params-Lasthenia_L1R2_miss.txt -b clust90 -f
sed -i '/\[14] /c\0.9 ## [14]' params-clust90.txt
ipyrad -p params-Lasthenia_L1R2_miss.txt -b clust92 -f
sed -i '/\[14] /c\0.92 ## [14]' params-clust92.txt
ipyrad -p params-Lasthenia_L1R2_miss.txt -b clust94 -f
sed -i '/\[14] /c\0.94 ## [14]' params-clust94.txt
ipyrad -b clust96 -p params-Lasthenia_L1R2_miss.txt -f
sed -i '/\[14] /c\0.96 ## [14]' params-clust96.txt
ipyrad -b clust98 -p params-Lasthenia_L1R2_miss.txt -f
sed -i '/\[14] /c\0.98 ## [14]' params-clust98.txt



ipyrad -p params-clust90.txt -s 34567 -c ${SLURM_NTASKS} -f 
ipyrad -p params-clust92.txt -s 34567 -c ${SLURM_NTASKS} -f 
ipyrad -p params-clust94.txt -s 34567 -c ${SLURM_NTASKS} -f 
ipyrad -p params-clust96.txt -s 34567 -c ${SLURM_NTASKS} -f 
ipyrad -p params-clust90.txt -s 34567 -c ${SLURM_NTASKS} -f 
ipyrad -p params-clust98.txt -s 34567 -c ${SLURM_NTASKS} -f 

#mkdir clust_vcfs

cp clust90_outfiles/clust90.vcf clust_vcfs
cp clust92_outfiles/clust92.vcf clust_vcfs
cp clust94_outfiles/clust94.vcf clust_vcfs
cp clust96_outfiles/clust96.vcf clust_vcfs
cp clust98_outfiles/clust98.vcf clust_vcfs

cd clust_vcfs

ls *.vcf > vcf_list.txt

perl clustOpt/vcfMissingness.pl --vcflist vcf_list.txt

Rscript clustOpt/vcfToPCAvarExplained.R vcf_list.txt 4


