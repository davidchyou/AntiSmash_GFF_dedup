# De-duplicate GFF3 annotations for AntiSmash analysis

**What it does?**

The [AntiSmash](https://antismash.secondarymetabolites.org/#!/start) webserver is a powerful bioinformatic tool for gene-expression network and metabolic pathway analysis, but fails when two or more genes in the GFF3 file have identical genomic coordinates but different IDs, and GFF3 files provided by NCBI often have this issue. Below is the error message one would see when genes in a GFF3 file are in duplicate.

        failed: Job returned errors: 
        ERROR	07/08 00:28:46   Multiple CDS features have the same location: join{[3866125:3866500](-), [3865941:3866028](-)}
        ERROR: Multiple CDS features have the same location: join{[3866125:3866500](-), [3865941:3866028](-)}
        e.g. 
        NC_089403.1 RefSeq           	CDS  	3866126            3866500        	.          	-          	0

This script creates a deduped GFF3 annotation file from the original GFF3 files where genes may be duplicated.
