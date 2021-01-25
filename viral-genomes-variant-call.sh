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
	outfile=$n.viral.fa
	echo $line > $outfile
    else
        echo $line >> $outfile
    fi
done < $query
echo 'split is done'
#pairwise alignment
samtools faidx $ref
name=$(cut -f1 ${ref}.fai)
length=$(cut -f2 ${ref}.fai)
echo "@SQ	SN:$name	LN:$length" > samheader.txt
for i in *.viral.fa
do
sam=${i%.fa}_aln.sam
fixsam=${i%.fa}_fix.sam
water -gapopen 10.0 -gapextend 0.5 -aformat3 sam -asequence $ref -bsequence $i -outfile $sam
cat samheader.txt $sam > $fixsam
rm $sam
done 
echo "alignment is done"
#SNPs calling
for i in *fix.sam
do
beforevcfname=${i%_fix.sam}.beforevcf
vcfname=${i%_fix.sam}.vcf
bam=${i%_fix.sam}.bam
samtools view -bS $i > $bam
bcftools mpileup -f $ref $bam > $beforevcfname
grep '#' $beforevcfname > $vcfname
grep 'QS=0,1,0' $beforevcfname >> $vcfname
rm $beforevcfname $bam $i 
done
rm *.viral.fa
echo "variant calling is done"
