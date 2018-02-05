##### normalize_google_trend.R #####
# Kuan-lin Huang @ WashU 2018 Feb

### dependencies ###
bdir = "/Users/khuang/Google\ Drive/ResearchProjects/PopularGenes"
setwd(bdir)
source("src/aes.R")

##### READ inputs #####
trend_data_f = "data/google_trends_human_genes_2004-2018_melted.csv"
trend_data = read.table(header=F,sep="\t",file = trend_data_f)
colnames(trend_data) = c("batch","month","gene","query")

##### normalize using the TP53 loading control #####
trend_data_norm = trend_data
# find the maximized value of TP53
i=1
rowNum = which(trend_data$query[trend_data$batch==i]==max(trend_data$query[trend_data$batch==i]))
trend_data[trend_data$batch==i,][rowNum,]
i=2
rowNum = which(trend_data$query[trend_data$batch==i]==max(trend_data$query[trend_data$batch==i]))
trend_data[trend_data$batch==i,][rowNum,]
i=3
rowNum = which(trend_data$query[trend_data$batch==i]==max(trend_data$query[trend_data$batch==i]))
trend_data[trend_data$batch==i,][rowNum,]

# use the TP53 peak query in 2004-05 as a loading control
for (i in 1:max(trend_data$batch)){
  TP53control = trend_data$query[trend_data$batch==i & trend_data$gene=="TP53" & trend_data$month =="2004-05"]
  trend_data_norm$query[trend_data_norm$batch==i] = trend_data_norm$query[trend_data_norm$batch==i]/TP53control
}

tn = "data/google_trends_human_genes_2004-2018_melted_normalized.csv"
write.table(trend_data_norm, quote=F, sep="\t", file = tn, row.names = F)

##### collapse these into by year data #####
trend_data_norm$year = gsub("-.*","",trend_data_norm$month)
trend_data_norm = trend_data_norm[!(trend_data_norm$gene == "TP53" & trend_data_norm$batch != 1),]
trend_data_norm_year = aggregate(x=trend_data_norm$query,by = list(trend_data_norm$gene,trend_data_norm$year),FUN="sum")
colnames(trend_data_norm_year) = c("gene","year","query")
trend_data_norm_year = trend_data_norm_year[trend_data_norm_year$gene != "TP53",]

tn = "data/google_trends_human_genes_2004-2018_melted_normalized_byYear.csv"
write.table(trend_data_norm_year, quote=F, sep="\t", file = tn, row.names = F)