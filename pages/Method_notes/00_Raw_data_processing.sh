#!/bin/bash
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu=16384
#SBATCH --partition=compute
#SBATCH --time=72:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=brooke.whitelaw@otago.ac.nz


module load fastp/0.23.2-GCC-11.3.0
module load FastQC/0.11.9
module load MultiQC/1.13-gimkl-2022a-Python-3.10.5


dirA="directory with input files"
species="Rr"
depth="30"

ID="ERR7428839
ERR7428840
ERR7428841
ERR7428842
ERR7428843
ERR7428844"


mkdir trimmed
mkdir fastqc_res


for i in $ID
do

#Remove adapters
$ fastp --detect_adapter_for_pe
        --overrepresentation_analysis
        --correction --cut_right --thread 2
        --html trimmed/anc.fastp.html --json trimmed/anc.fastp.json
        -i $dirA/$i\_R1.fastq.gz -I $dirA/$i\_R2.fastq.gz
        -o trimmed/$i\_R1.fastq.gz -O trimmed/$i\_R2.fastq.gz

#FastQC

fastqc -o fastqc_res trimmed/$i\_R1.fastq.gz -O trimmed/$i\_R2.fastq.gz

done

#MutiQC

multiqc fastqc_res



