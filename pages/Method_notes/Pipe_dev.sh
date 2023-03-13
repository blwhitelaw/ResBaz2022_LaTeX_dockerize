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

# bcftools mpileup -Ou -f ref.fa prefix1.bam prefix2.bam ... prefixn.bam | bcftools call -Ov -mv -o prefix.multi.var.vcf 
# vcftools --vcf prefix.multi.var.vcf --remove-indels --recode --recode-INFO-all --out prefix.multi.snp

bcftools mpileup -Ou -f GCF_015227675.2_mRatBN7.2_genomic.fna RR7428843_10Ksub_sorted.bam | bcftools call -Ov -mv -o RR7428843_10Ksub.multi.var.vcf 
vcftools --vcf RR7428843_10Ksub.multi.var.vcf  --remove-indels --recode --recode-INFO-all --out  RR7428843_10Ksub.multi.snp


#GATK
#gatk Haplotype caller

gatk --java-options "-Xmx4g" HaplotypeCaller  \
   -R GCF_015227675.2_mRatBN7.2_genomic.fna \
   -I input.bam \
   -O output.vcf.gz \
   -bamout bamout.bam

gatk --java-options "-Xmx4g" HaplotypeCaller -R GCF_015227675.2_mRatBN7.2_genomic.fna  -I ERR7428842_sorted.bam -O ERR7428842_sorted_GATK.vcf.gz


java -jar picard.jar MergeVcfs I= *GATK.vcf.gz O=gatk_comb.vcf.gz


##Calling SVs

#Parliment2: https://hub.docker.com/r/dnanexus/parliament2/ #Failed 

docker run -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/:/home/dnanexus/in/None -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/Parli/:/home/dnanexus/out dnanexus/parliament2:latest   --bam RR7428843_10Ksub.bam --bai RR7428843_10Ksub_sorted.bam.bai -r GCF_015227675.2_mRatBN7.2_genomic.fna  --lumpy

docker run -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/:/home/dnanexus/in -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/Parli/:/home/dnanexus/out dnanexus/parliament2:latest   --bam RR7428843_10Ksub.bam -r GCF_015227675.2_mRatBN7.2_genomic.fna  --lumpy

#PerSVade https://github.com/Gabaldonlab/perSVade/wiki/3.-Test-installation 

#Singu install
singularity build --docker-login ./mikischikora_persvade_v1.02.6.sif docker://mikischikora/persvade:v1.02.6

#Docker installation
docker pull mikischikora/persvade:v1.02.6

#Test installation
mkdir perSVade_testing_outputs

docker run -v $PWD/perSVade_testing_outputs:/perSVade/installation/test_installation/testing_outputs mikischikora/persvade:v1.02.6 python -u ./installation/test_installation/test_installation_modules.py

#Run

docker run -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/PV_test:/reference_genome_dir -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/PV_test:/output_directory -v /Users/brooke/Library/CloudStorage/OneDrive-UniversityofOtago/NCBI_pipe_dev/PV_test:/reads  mikischikora/persvade:v1.02.6 python -u ./scripts/perSVade align_reads -r /output_directory/reference_genome.fasta -o /output_directory -f1 /reads/SRR9221193_sub10k_1.fastq.gz -f2 /reads/SRR9221193_sub10k_2.fastq.gz --fraction_available_mem 0.6