#!bin/bash

##Align fastq to ref genome 

#make index
bwa index GCF_015227675.2_mRatBN7.2_genomic.fna.gz

#Align
#for the purpose of tesing pipelines the fastq file will be randomly subsampled using seqtk

seqtk sample ERR7428843.fastq.gz 10000 > ERR7428843_10Ksub.fastq

bwa mem GCF_015227675.2_mRatBN7.2_genomic.fna.gz ERR7428843_10Ksub.fastq > RR7428843_10Ksub.sam 

#Convert to bam and sort 

samtools view -S -b RR7428843_10Ksub.sam > RR7428843_10Ksub.bam
samtools sort RR7428843_10Ksub.bam -o RR7428843_10Ksub_sorted.bam
samtools index RR7428843_10Ksub_sorted.bam



##Calling SNPs . paper comparing tools https://doi.org/10.1371/journal.pone.0262574

#bcftools multiple 

bcftools mpileup -Ou -f ref.fa prefix1.bam prefix2.bam ... prefixn.bam | bcftools call -Ov -mv -o prefix.multi.var.vcf 
vcftools --vcf prefix.multi.var.vcf --remove-indels --recode --recode-INFO-all --out prefix.multi.snp


#GATK
gatk Haplotype caller





##Calling SVs

#Parliment2: https://hub.docker.com/r/dnanexus/parliament2/ #Failed 

docker run -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/:/home/dnanexus/in/None -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/Parli/:/home/dnanexus/out dnanexus/parliament2:latest   --bam RR7428843_10Ksub.bam --bai RR7428843_10Ksub_sorted.bam.bai -r GCF_015227675.2_mRatBN7.2_genomic.fna  --lumpy

docker run -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/:/home/dnanexus/in -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/Parli/:/home/dnanexus/out dnanexus/parliament2:latest   --bam RR7428843_10Ksub.bam -r GCF_015227675.2_mRatBN7.2_genomic.fna  --lumpy

#PerSVade https://github.com/Gabaldonlab/perSVade/wiki/3.-Test-installation 

#Docker installation
docker pull mikischikora/persvade:v1.02.6

#Test installation
mkdir perSVade_testing_outputs

docker run -v $PWD/perSVade_testing_outputs:/perSVade/installation/test_installation/testing_outputs mikischikora/persvade:v1.02.6 python -u ./installation/test_installation/test_installation_modules.py

#Run
