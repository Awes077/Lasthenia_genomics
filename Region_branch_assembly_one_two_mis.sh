#!/bin/bash
#SBATCH --partition=amilan
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aawe2235@colorado.edu
#SBATCH --job-name=Region_branching
#SBATCH --output Branch_north_south_central.txt

module purge
module load anaconda
conda activate ipyrad

cd /scratch/alpine/aawe2235/Lasthenia_genomics/RADseqII/RAWseq/Lane1/Lane1_Run2RawUnfiltered/

#create first overall project
ipyrad -n Lasthenia_Lane1_Run2 -f 

#set necessary paths for basic run, where our raw fastqs and barcodes are, set output to return ALL file types, set restriction overhang to Sfb1's overhang
sed -i '/\[2] /c\/scratch/alpine/aawe2235/Lasthenia_genomics/RADseqII/RAWseq/Lane1/Lane1_Run2RawUnfiltered/raw/014504_lane1_NoIndex_run381_L001_001.fastq ## [2]' params-Lasthenia_Lane1_Run2.txt
sed -i '/\[3] /c\/scratch/alpine/aawe2235/Lasthenia_genomics/RADseqII/RAWseq/Lane1/Lane1_Run2RawUnfiltered/barcodes/ipy_barcodes.txt ## [3]' params-Lasthenia_Lane1_Run2.txt
sed -i '/\[27] /c\* ## [27]' params-Lasthenia_Lane1_Run2.txt
sed -i '/\[8] /c\ACGTCC, ## [8]' params-Lasthenia_Lane1_Run2.txt


#create branches for one mismatch and two mismatches with barcode 
ipyrad -b one_b_mis -p params-Lasthenia_Lane1_Run2.txt -f

sed -i '/\[15] /c\1 ## [15]' params-one_b_mis.txt



#go ahead and demultiplex since this isnt special to any single set of populations - but want to make sure we do this AFTER first branch since mismatch threshold affects
#demultiplexing!
ipyrad -p params-one_b_mis.txt -s 1 -c ${SLURM_NTASKS} -f




#now branch by vernal pool region, north, central, and south, for each of our mismatch settings, then run the full assembly for each, and then finally run a full assembly 
#for non-region-branched mismatch levels for comparison

ipyrad -p params-one_b_mis.txt -b north_r_one DL2_6 DL2_7 DL4_1 DL4_2 DL4_4 VINAA_2 VINAA_4 VINAC_1 VINAC_2 NTM1_1 NTM1_2 NTM1_4 NTM21

ipyrad -p params-north_r_one.txt -s 234567 -c ${SLURM_NTASKS} -f



ipyrad -p params-one_b_mis.txt -b cent_r_one JP1_1 JP1_2 JP1_4 JP3_1 JP3_2 GT1_2 GT1_3 GT18 GT2_1 GT2_4 MF2_10 MF2_13 MF2_9 MF4_4 MF4_7

ipyrad -p params-cent_r_one.txt -s 234567 -c ${SLURM_NTASKS} -f 



ipyrad  -p params-one_b_mis.txt -b south_r_one CARR3_3 CARR3_4 CARR3_5 PVP1_48 PVP1_75 PVP1_7 PVP3_2 PVP3_3 BTM1_5 BTM1_6 BTM1_8 BTM2_4 BTM2_6

ipyrad -p params-south_r_one.txt -s 2344567 -c ${SLURM_NTASKS} -f



#non-regional assemblies here

ipyrad -p params-one_b_mis.txt -s 234567 -c ${SLURM_NTASKS} -f 

