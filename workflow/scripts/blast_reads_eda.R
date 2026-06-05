suppressPackageStartupMessages(library("tidyverse"))

args = commandArgs(trailingOnly=TRUE)
# args <- NULL
# args[1] <- "results/work/GDE_IonXpress_040/GDE_IonXpress_040_reads_species.tsv"
# args[2] <- "results/work/GDE_IonXpress_040/GDE_IonXpress_040_reads_human.tsv"

cn <- c("read", "ref", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

pha <- read.delim(args[1], sep = "\t", col.names = cn) %>% distinct(read, .keep_all = T)
pha$ref <- "nonhuman"
hum <- read.delim(args[2], sep = "\t", col.names = cn) %>% distinct(read, .keep_all = T)
hum$ref <- "human"

diff_df <- bind_rows(pha, hum) %>% 
  select(read, ref, pident) %>% 
  pivot_wider(names_from = ref, values_from = pident) %>% 
  filter(nonhuman>human | is.na(human))

writeLines(unique(diff_df$read), args[3])
