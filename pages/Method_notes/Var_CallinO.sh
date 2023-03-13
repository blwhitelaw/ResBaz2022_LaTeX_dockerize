#!/bin/bash
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu=16384
#SBATCH --partition=compute
#SBATCH --time=72:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=brooke.whitelaw@otago.ac.nz


# module load bcftools
# module load vcftools
# module load gatk/4.0.11.0


REF=GCF_015227675.2_mRatBN7.2_genomic.fna
dirA="directory with input files"
species="Rr"
depth="30"

ID="ERR7428839
ERR7428840
ERR7428841
ERR7428842
ERR7428843
ERR7428844"


for i in $ID
do

#Align test set
bwa mem $REF $i\_.fastq > $i\_.sam 

#Convert to bam and sort 
samtools view -S -b $i\_.sam > $i\_.bam
samtools sort $i\_.bam -o $i\__sorted.bam
samtools index $i\__sorted.bam

#BCFTOOLS METHOD SNP
 bcftools mpileup -Ou -f $REF $i\__sorted.bam | bcftools call -Ov -mv -o $i\_$species\_$depth\_.var.vcf 

 vcftools --vcf $i\_$species\_$depth\_.var.vcf  --remove-indels --recode --recode-INFO-all --out  $i\_$species\_$depth\_.snp

done

