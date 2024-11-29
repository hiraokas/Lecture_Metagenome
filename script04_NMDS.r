#==========================================================================================
#  Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  PCA analysis for taxonomic count table
#  created:  20241110
#  History:  20241118
#==========================================================================================

.libPaths("./rlib")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("ggplot2"))      install.packages("ggplot2")
if (!require("tidyverse"))    install.packages("tidyverse")
if (!require("vegan"))        install.packages("vegan")

#データセットの作成
data_phylum1 = read.table("taxonomy/DRR267104.phylum.tsv", header=T, sep="\t")
data_phylum2 = read.table("taxonomy/DRR267106.phylum.tsv", header=T, sep="\t")
data_phylum3 = read.table("taxonomy/DRR267108.phylum.tsv", header=T, sep="\t")
data_phylum4 = read.table("taxonomy/DRR267110.phylum.tsv", header=T, sep="\t")

#結合、サンプル名カラムの追加
data_phylum        = rbind(data_phylum1, data_phylum2, data_phylum3, data_phylum4)
data_phylum$sample = sub("taxonomy/", "", sub(".kaiju.out", "", data_phylum$file))

#unclassifiedなデータを削除し、系統推定できたものだけで計算を進める
`%ni%` <- Negate(`%in%`)
data_table = data_phylum[data_phylum$taxon_id %ni% NA,] %>% 
             select(sample, taxon_name, percent) %>% 
             pivot_wider(names_from = taxon_name, values_from = percent) 

#数値のみの行列を取得
data_matrix= data.matrix(data_table[, colnames(data_table) != "sample"])

#各サンプルで合計が100%になるように再計算
data_matrix = data_matrix / rowSums(data_matrix) * 100

#NMDS
nmds = metaMDS(data_matrix, distance = "bray", k = 2, trymax = 20)
data.scores = as.data.frame(scores(nmds)$sites)  
data.scores$sample = data_table$sample
    
#plot
g = ggplot(data = data.scores,
           aes(x = NMDS1,
               y = NMDS2,
               color = sample)) 
g = g + theme_bw()
g = g + geom_point(show.legend = TRUE,
                   alpha       = 0.7,
                   size        = 5)
g = g + guides(color = guide_legend(byrow = TRUE))
g = g + theme(legend.key.size = unit(1.5, "cm"),
              legend.title    = element_text(size   = 25),
              legend.text     = element_text(size   = 20),
              axis.text       = element_text(colour = "black"),
              axis.title.x    = element_text(size   = 26),
              axis.title.y    = element_text(size   = 26),
              axis.text.x     = element_text(size   = 20),
              axis.text.y     = element_text(size   = 20),
              axis.line       = element_line(colour = "black"),
              plot.margin     = unit(c(0.2,0,0,0), "lines")) 
plot(g)
