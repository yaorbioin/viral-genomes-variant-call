#!/bin/bash 
file="/Users/renyao/Desktop/pairwise/test.fa"
#split the big fasta file to multiple fasta files containing one sequence in one file
query=$1
ref=$2
n=0
while read line
do
    if [[ ${line:0:1} == '>' ]]
    then
        n=$((n+1))
	outfile=$n.fa
	echo $line > $outfile
    else
        echo $line >> $outfile
    fi
done < $query
echo 'split is done'
#pairwise alignment
echo '@SQ	SN:NC_045512.2	LN:29903' > samheader.txt
for i in *.fa
do
sam=${i%.fa}_aln.sam
fixsam=${i%.fa}_fix.sam
water -gapopen 10.0 -gapextend 0.5 -aformat3 sam -asequence $ref -bsequence $i -outfile $sam
cat samheader.txt $sam > $fixsam
done 
echo "alignment is done"
#SNPs calling
echo '##fileformat=VCFv4.2
##FILTER=<ID=PASS,Description="All filters passed">
##bcftoolsVersion=1.11+htslib-1.11
##reference=file://SARS-CoV-2_complete_genome.fasta
##contig=<ID=NC_045512.2,length=29903>
##ALT=<ID=*,Description="Represents allele(s) other than observed.">
##INFO=<ID=INDEL,Number=0,Type=Flag,Description="Indicates that the variant is an INDEL.">
##INFO=<ID=IDV,Number=1,Type=Integer,Description="Maximum number of raw reads supporting an indel">
##INFO=<ID=IMF,Number=1,Type=Float,Description="Maximum fraction of raw reads supporting an indel">
##INFO=<ID=DP,Number=1,Type=Integer,Description="Raw read depth">
##INFO=<ID=VDB,Number=1,Type=Float,Description="Variant Distance Bias for filtering splice-site artefacts in RNA-seq data (bigger is better)",Version="3">
##INFO=<ID=RPB,Number=1,Type=Float,Description="Mann-Whitney U test of Read Position Bias (bigger is better)">
##INFO=<ID=MQB,Number=1,Type=Float,Description="Mann-Whitney U test of Mapping Quality Bias (bigger is better)">
##INFO=<ID=BQB,Number=1,Type=Float,Description="Mann-Whitney U test of Base Quality Bias (bigger is better)">
##INFO=<ID=MQSB,Number=1,Type=Float,Description="Mann-Whitney U test of Mapping Quality vs Strand Bias (bigger is better)">
##INFO=<ID=SGB,Number=1,Type=Float,Description="Segregation based metric.">
##INFO=<ID=MQ0F,Number=1,Type=Float,Description="Fraction of MQ0 reads (smaller is better)">
##FORMAT=<ID=PL,Number=G,Type=Integer,Description="List of Phred-scaled genotype likelihoods">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##INFO=<ID=ICB,Number=1,Type=Float,Description="Inbreeding Coefficient Binomial test (bigger is better)">
##INFO=<ID=HOB,Number=1,Type=Float,Description="Bias in the number of HOMs number (smaller is better)">
##INFO=<ID=AC,Number=A,Type=Integer,Description="Allele count in genotypes for each ALT allele, in the same order as listed">
##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
##INFO=<ID=DP4,Number=4,Type=Integer,Description="Number of high-quality ref-forward , ref-reverse, alt-forward and alt-reverse bases">
##INFO=<ID=MQ,Number=1,Type=Integer,Description="Average mapping quality">
##bcftools_callVersion=1.11+htslib-1.11
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  1.bam' > header.txt
for i in *fix.sam
do
beforevcfname=${i%_fix.sam}.beforevcf
vcfname=${i%_fix.sam}.vcf
bam=${i%_fix.sam}.bam
samtools view -bS $i > $bam
bcftools mpileup -f $ref 1.bam| grep 'QS=0,1,0' > $beforevcfname
cat header.txt $beforevcfname > $vcfname
done
mkdir vcf
mv *.vcf vcf/
echo "variant calling is done"