##### merge_gene_avail.R #####
# Kuan-lin Huang 2018 March

### dependencies ###
bdir = "/Users/khuang/Google\ Drive/ResearchProjects/PopularGenes"
setwd(bdir)
source("src/aes.R")


##### READ inputs #####
avail_data_f = "data/hugo_genes_availability.txt"
avail_data = read.table(header=T,sep="\t",file = avail_data_f)
colnames(avail_data) = c("HGNC_ID","gene","GoogleTrendName")

research_data_f = "data/gene_info_by_year.new.tsv"
research_data = read.table(row.names = NULL,header=T,sep="\t",file = research_data_f,fill=T)
colnames(research_data) = c("SpeciesID","NCBIGeneID","year","gene","GeneType","GeneType2","CitationCount")
research_data_human = research_data[research_data$SpeciesID == 9606,]
#research_data_human = transform(research_data_human, sum_name = ave(CitationCount, gene, FUN = sum))
research_data_human$CitationCount = as.numeric(as.character(research_data_human$CitationCount))
research_data_human_sum = ddply(research_data_human, .(gene), summarise, CitationCount=sum(CitationCount))
summary(research_data_human_sum$CitationCount)
table(research_data_human_sum$CitationCount>500)


gene_data = merge(avail_data,research_data_human_sum,by=c("gene"),all.x=T)
tn = "data/hugo_genes_availability_wCitationCount.txt"
write.table(gene_data, quote=F, sep="\t", file = tn, row.names = F)
