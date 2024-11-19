#==========================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created: 20241120
#  History: 20241120
#==========================================================================================

.libPaths("./rlib")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("ggplot2"))      install.packages("ggplot2")
if (!require("tidyverse"))    install.packages("tidyverse")

#データセットの読み込み、結合
files = list.files("annotation/", pattern="_eggnog.category.tsv", full.names = T)
cog_count = do.call(rbind, lapply(files, function(x)(read.table(x, header=F, sep="\t", row.names=NULL))))
colnames(cog_count) = c("sample", "category", "count")
cog_count = cog_count[cog_data$category != "-",]

#サンプルあたりの遺伝子数リストを与えて、相対存在率を算出
sample_CDSnum = data.frame("DRR267104" = 429344322,
                           "DRR267106" = 471502430,
                           "DRR267108" = 373133956,
                           "DRR267110" = 413969472)
cog_data = cog_count %>% 
    mutate(CDSnum = as.numeric(sample_CDSnum[sample])) %>% 
    mutate(ratio = count / CDSnum)

category_function = c(
"J" = "Translation, ribosomal structure and biogenesis",
"A" = "RNA processing and modification",
"K" = "Transcription",
"L" = "Replication, recombination and repair",
"B" = "Chromatin structure and dynamics",
"D" = "Cell cycle control, cell division, chromosome partitioning",
"Y" = "Nuclear structure",
"V" = "Defense mechanisms",
"T" = "Signal transduction mechanisms",
"M" = "Cell wall/membrane/envelope biogenesis",
"N" = "Cell motility",
"Z" = "Cytoskeleton",
"W" = "Extracellular structures",
"U" = "Intracellular trafficking, secretion, and vesicular transport",
"O" = "Posttranslational modification, protein turnover, chaperones",
"C" = "Energy production and conversion",
"G" = "Carbohydrate transport and metabolism",
"E" = "Amino acid transport and metabolism",
"F" = "Nucleotide transport and metabolism",
"H" = "Coenzyme transport and metabolism",
"I" = "Lipid transport and metabolism",
"P" = "Inorganic ion transport and metabolism",
"Q" = "Secondary metabolites biosynthesis, transport and catabolism",
"R" = "General function prediction only",
"S" = "Function unknown")

#作図
g = ggplot(cog_data, 
            aes (x    = factor(category, levels=rev(sort(category))),  
                 y    = ratio,
                 fill = sample))
g = g + theme_bw()
g = g + geom_bar(width  = 0.8,
                 stat   = "identity",
                 position = "dodge",
                 colour = "black")
g = g + coord_flip() 
g = g + xlab(NULL) + ylab("相対存在量 (%)")
g = g + guides(fill = guide_legend(reverse = TRUE, ncol = 1))
g = g + scale_y_continuous(expand = c(0,0))
g = g + theme(axis.title       = element_text(size = 20),
              axis.text.x      = element_text(size = 20, colour = "black"),
              axis.text.y      = element_text(size = 16, colour = "black"),
              axis.ticks.y     = element_blank(),
              axis.ticks.x     = element_line(size=1.3),
              axis.line        = element_line(size=1.3),
              legend.text      = element_text(size = 16),
              legend.title     = element_blank(),
              legend.position  = "right",
              plot.margin      = unit(c(0.5, 0.1, 0, 01), "cm"),
              panel.border     = element_rect(color  = NA, fill = NA))
plot(g)
