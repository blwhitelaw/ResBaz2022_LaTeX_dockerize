#!bin/bash


seqtk sample -s 10 SRR9221193_1.fastq.gz 10000 > SRR9221193_10K_1_R1.fastq
seqtk sample -s 10 SRR9221193_2.fastq.gz 10000 > SRR9221193_10K_1_R2.fastq

seqtk sample -s 50 SRR9221193_1.fastq.gz 10000 > SRR9221193_10K_2_R1.fastq
seqtk sample -s 50 SRR9221193_2.fastq.gz 10000 > SRR9221193_10K_2_R2.fastq

seqtk sample -s 100 SRR9221193_1.fastq.gz 10000 > SRR9221193_10K_3_R1.fastq
seqtk sample -s 100 SRR9221193_2.fastq.gz 10000 > SRR9221193_10K_3_R2.fastq

seqtk sample -s 150 SRR9221193_1.fastq.gz 10000 > SRR9221193_10K_4_R1.fastq
seqtk sample -s 150 SRR9221193_2.fastq.gz 10000 > SRR9221193_10K_4_R2.fastq

seqtk sample -s 200 SRR9221193_1.fastq.gz 10000 > SRR9221193_10K_5_R1.fastq
seqtk sample -s 200 SRR9221193_2.fastq.gz 10000 > SRR9221193_10K_5_R2.fastq