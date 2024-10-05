my $gff = "";
my $out = "NA";

my $ind = 0;
foreach(@ARGV) {

	if (@ARGV[$ind] eq '-gff') {
		$gff = @ARGV[$ind + 1];
		if (! (-e $gff)) {
			die "cannot open genomic file: $gff\n";
		}
	}
	
	if (@ARGV[$ind] eq '-out') {
		$out = @ARGV[$ind + 1];
	}
	
	$ind++;
}

if ($out eq "NA") {
	$out = "$gff.dedup.gff3";
}

my %parent_lookup=();

open(GENE, ">$gff.gene.gff");
open(MRNA, ">$gff.mrna.gff");
open(GFF, $gff);
while(my $line = <GFF>) {
	chomp $line;

	if ($line =~ /^#/) {
		next;
	}

	my @toks = split(/[\t]/, $line);
	my $type = $toks[2];
	my $comment = $toks[8];
	
	my $id = "-";
	if ($comment =~ /ID=/) {
		($id) = ($comment =~ /ID=([^;]+)/i);
	}
	
	my $parent = "-";
	if ($comment =~ /Parent=/) {
		($parent) = ($comment =~ /Parent=([^;]+)/i);
	}
	
	if ($parent ne "-" and $id ne "-" and not exists $parent_lookup{$id}) {
		$parent_lookup{$id} = $parent;
	}
	
	if ($type eq "gene") {
		print GENE "$line\n";
	} else {
		if ($type ne "exon" and $type ne "CDS" and $type ne "region") {
			print MRNA "$line\n";
		}
	}
}
close(GFF);
close(GENE);
close(MRNA);

system("bedtools cluster -i $gff.gene.gff -s -d 1 > $gff.gene.cluster.txt");

my %clust_gene_lookup = ();
my %gene_clust_lookup = ();

open(CLUST_1, "$gff.gene.cluster.txt");
while(my $line = <CLUST_1>) {
	chomp $line;
	
	my @toks = split(/[\t]/, $line);
	my $comment = $toks[8];
	my $clust = $toks[9] + 0;
	
	my $id = "-";
	if ($comment =~ /ID=/) {
		($id) = ($comment =~ /ID=([^;]+)/i);
	}
	
	if ($id ne "-" and $clust > 0 and not exists $clust_gene_lookup{$clust}) {
		$clust_gene_lookup{$clust} = $id;
		$gene_clust_lookup{$id} = $clust;
	}
	
}
close(CLUST_1);

system("bedtools cluster -i $gff.mrna.gff -s -d 1 > $gff.mrna.cluster.txt");

my %clust_mrna_lookup = ();
my %mrna_clust_lookup = ();

open(CLUST_2, "$gff.mrna.cluster.txt");
while(my $line = <CLUST_2>) {
	chomp $line;
	
	my @toks = split(/[\t]/, $line);
	my $comment = $toks[8];
	my $clust = $toks[9] + 0;
	
	my $id = "-";
	if ($comment =~ /ID=/) {
		($id) = ($comment =~ /ID=([^;]+)/i);
	}
	
	if ($id ne "-" and $clust > 0 and not exists $clust_mrna_lookup{$clust}) {
		$clust_mrna_lookup{$clust} = $id;
		$mrna_clust_lookup{$id} = $clust;
	}
	
}
close(CLUST_1);

open(DEDUP, ">$out");
open(GFF, $gff);
while(my $line = <GFF>) {
	chomp $line;

	if ($line =~ /^#/) {
		next;
	}

	my @toks = split(/[\t]/, $line);
	my $type = $toks[2];
	my $comment = $toks[8];
	
	my $id = "-";
	if ($comment =~ /ID=/) {
		($id) = ($comment =~ /ID=([^;]+)/i);
	}
	
	my $parent = "-";
	if ($comment =~ /Parent=/) {
		($parent) = ($comment =~ /Parent=([^;]+)/i);
	}
	
	if ($type eq "gene") {
		if ($id ne "-" and exists $gene_clust_lookup{$id}) {
			print DEDUP "$line\n";
		}
	} else {
		if ($parent ne "-" and $id ne "-") {
			if (exists $mrna_clust_lookup{$id} or exists $mrna_clust_lookup{$parent_lookup{$id}}) {
				if (exists $parent_lookup{$id} or exists $parent_lookup{$parent_lookup{$id}}) {
					print DEDUP "$line\n";
				}
			}
		}
	}
}
close(DEDUP);

unlink("$gff.gene.gff");
unlink("$gff.gene.cluster.txt");
unlink("$gff.mrna.gff");
unlink("$gff.mrna.cluster.txt");
