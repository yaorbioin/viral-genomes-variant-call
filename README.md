# viral-genomes-variant-call
variant call for similar virus genomes comparison


Installation 
you will need 
  1.EMBOSS
  2.Samtools
  3.BCFtools
  

Executing the pipeline

bash viral-genomes-variant-call.sh query.fa  reference.fa

Test
the query file for test is test.fa
the reference file for test is SARS-CoV-2_complete_genome.fasta

Command 
bash viral-genomes-variant-call.sh test.fa SARS-CoV-2_complete_genome.fasta

it will generate 2 variant call file (VCF) containing SNPs for each genome.

