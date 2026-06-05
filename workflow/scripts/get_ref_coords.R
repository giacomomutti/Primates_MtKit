#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
# args <- NULL
# args[1] <- "results/vcf/NC_012761.1/reordered_msa.fa"
# args[2] <- "NC_012761.1"
# args[3] <- "results/vcf/NC_012761.1/NC_012761.1_msa.vcf"

msa_mt <- Biostrings::readDNAMultipleAlignment(args[1])

ref <- args[2]
# ref <- "CM003113.1"
vcf_file <- args[3]
# vcf_file <- "data/mts_primates/mafft_mts_primates_cox_2.vcf"
id_ref <- grep(ref, names(msa_mt@unmasked))

ref_seq <- msa_mt@unmasked[[id_ref]]

get_idx <- function(idxs, ref) {
  gaps <- stringr::str_locate_all(ref, "-")[[1]]
  to_remove <- sum(gaps[,1]<idxs)
  return(idxs - to_remove)
}

mt_vcf <- readr::read_delim(vcf_file, delim = "\t", comment = "##")

# remove non canonical sites (W and K as pathphynder does not like them)
mt_vcf <- mt_vcf[which(grepl("A|T|G|C", mt_vcf$ALT)),]
mt_vcf <- mt_vcf[which(grepl("A|T|G|C", mt_vcf$REF)),]

new_coord <- sapply(mt_vcf$POS, function (x) get_idx(x, as.character(ref_seq)))

mt_vcf$POS <- new_coord
mt_vcf$`#CHROM` <- ref

len_mt <- nchar(gsub("-","",ref_seq))
mt_vcf <- mt_vcf[mt_vcf$POS <= len_mt,]

# out_file <- paste0(dirname(args[3]), "/", ref,"_sorted.vcf")

cat("##fileformat=VCFv4.1\n##contig=<ID=",ref,",length=",len_mt,">\n##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n", 
    sep = "", file = args[4])

readr::write_delim(mt_vcf, args[4], delim = "\t", append = T, quote = "none", col_names = T)
