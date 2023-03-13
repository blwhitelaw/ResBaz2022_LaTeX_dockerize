REF=GCF_015227675.2_mRatBN7.2_genomic.fna
dirA="directory with input files"
species="Rr"
depth="30"

ID="SRR9221193_10K_1
SRR9221193_10K_2
SRR9221193_10K_3
SRR9221193_10K_4
SRR9221193_10K_5"



  #Generate dict 
    # java -jar picard.jar CreateSequenceDictionary \ 
    #       R=$REF \


for i in $ID
do
  #Prep and align test set
      bwa mem $REF $i\_R1.fastq  $i\_R2.fastq > $i\.sam 

  #Convert to bam and sort 

     samtools view -S -b $i\.sam > $i\.bam
     samtools sort $i\.bam -o $i\_sorted.bam
     samtools index $i\_sorted.bam


  #BCFTOOLS METHOD SNP
       bcftools mpileup -Ou -f $REF $i\_sorted.bam | bcftools call -Ov -mv -o $i\_$species\_$depth\_bcf.vcf 

       vcftools --vcf $i\_$species\_$depth\_bcf.vcf  --remove-indels --recode --recode-INFO-all --out  $i\_$species\_$depth\_.snp 
      
       bcftools view -O z --max-alleles 2 -o $i\_$species\_$depth\_.snp.recode.vcf.gz  $i\_$species\_$depth\_.snp.recode.vcf
       bcftools index $i\_$species\_$depth\_.snp.recode.vcf.gz  


  #GATK METHOD SNP

    samtools addreplacerg -r '@RG\tID:samplename\tSM:samplename' $i\_sorted.bam -o $i\_sorted_tag.bam
    samtools index $i\_sorted_tag.bam

    gatk --java-options "-Xmx4g" HaplotypeCaller\
        -R $REF \
        -I $i\_sorted_tag.bam \
        -O $i\_$species\_$depth\_GATK_SNM.vcf.gz
       

    java -jar picard.jar RenameSampleInVcf \
          INPUT=$i\_$species\_$depth\_GATK_SNM.vcf.gz  \
          OUTPUT=$i\_$species\_$depth\_GATK.vcf.gz  \
          NEW_SAMPLE_NAME=$i

      

done


#Merge VCFs
ls *GATK.vcf.gz > gatk_vcf_list.txt
ls *snp.recode.vcf.gz > var_vcf_list.txt

java -jar picard.jar MergeVcfs \
          I=gatk_vcf_list.txt \
          O=$species\_gatk_comb.vcf.gz

gunzip Rr_gatk_comb.vcf.gz
bcftools merge -O z --file-list var_vcf_list.txt > $species\_bcf_comb.vcf.gz

#Clean
mkdir $species\_$depth\_Var_calling_out
mv ERR* $species\_$depth\_Var_calling_out 
tar -czvf $species\_$depth\_Var_calling_out.tar.gz $species\_$depth\_Var_calling_out
rm *list.txt
