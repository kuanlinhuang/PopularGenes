##### normalize_google_trend.R #####
# Kuan-lin Huang @ WashU 2018 Feb

### dependencies ###
bdir = "/Users/khuang/Google\ Drive/ResearchProjects/PopularGenes"
setwd(bdir)
source("src/aes.R")

##### READ inputs #####
trend_data_f = "data/google_trends_human_genes_2004-2018_melted.csv"
trend_data = read.table(header=F,sep="\t",file = trend_data_f, stringsAsFactors = F)
colnames(trend_data) = c("batch","month","query_name","query")

avail_data_f = "data/hugo_genes_availability_wCitationCount_added.txt"
avail_data = read.table(header=T,sep="\t",file = avail_data_f, stringsAsFactors = F)
### map back to gene names
# table(avail_data$GoogleTrendName)[table(avail_data$GoogleTrendName)>1]
# if NA: gene name
# if any of the "Gene Protein   Topic": gene name
# if any of the Topic/Gene/Protein (query_name)
# anything else: query_name directly
avail_data$GoogleTrendName = gsub("Topic \\(","",avail_data$GoogleTrendName)
avail_data$GoogleTrendName = gsub("Gene \\(","",avail_data$GoogleTrendName)
avail_data$GoogleTrendName = gsub("Protein \\(","",avail_data$GoogleTrendName)
avail_data$GoogleTrendName = gsub("\\)","",avail_data$GoogleTrendName)
avail_data$GoogleTrendName[avail_data$GoogleTrendName %in% c("Gene","Protein","Topic","Topic=")]=NA
avail_data$query_name = avail_data$GoogleTrendName
avail_data$query_name[is.na(avail_data$query_name)] = avail_data$gene[is.na(avail_data$query_name)]

trend_data = merge(trend_data,avail_data,by="query_name")

trend_data = trend_data[,-which(colnames(trend_data)=="CitationCount")]
trend_data = trend_data[,-which(is.na(colnames(trend_data)))]

trend_data$query = as.numeric(trend_data$query)

trend_data$year = gsub("-.*","",trend_data$month)
trend_data = trend_data[trend_data$year != 2018,] # 2018 data is uneven for now

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
#trend_data_norm = trend_data_norm[!(trend_data_norm$gene == "TP53" & trend_data_norm$batch != 1),]
trend_data_norm = trend_data_norm[!duplicated(paste(trend_data_norm$query_name,trend_data_norm$month)),]
trend_data_norm_mapping = trend_data_norm[,c("query_name","gene")]
trend_data_norm_mapping = trend_data_norm_mapping[!duplicated(trend_data_norm_mapping$query_name),]
trend_data_norm_year = aggregate(x=trend_data_norm$query,by = list(trend_data_norm$query_name,trend_data_norm$year),FUN="sum")
colnames(trend_data_norm_year) = c("query_name","year","query")
trend_data_norm_year = merge(trend_data_norm_year,trend_data_norm_mapping,by="query_name")

tn = "data/google_trends_human_genes_2004-2018_melted_normalized_byYear.csv"
write.table(trend_data_norm_year, quote=F, sep="\t", file = tn, row.names = F)