# De-duplicate GFF3 annotations for AntiSmash analysis

**What it does?**

The [AntiSmash](https://antismash.secondarymetabolites.org/#!/start) webserver is a powerful bioinformatic tool for gene-expression network and metabolic pathway analysis, but fails when two or more genes in the GFF3 file have identical genomic coordinates but different ID, and GFF3 files provided by NCBI often have this issue.

