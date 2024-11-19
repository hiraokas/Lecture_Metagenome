#==========================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created: 20241110
#  History: 20241120
#==========================================================================================

.libPaths("./rlib")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("ggplot2"))      install.packages("ggplot2")
if (!require("tidyverse"))    install.packages("tidyverse")

#データセットの読み込み、結合
files = list.files("taxonomy/", pattern="phylum.tsv", full.names = T)
data_phylum = do.call(rbind, lapply(files, function(x)(read.table(x, header=T, sep="\t", row.names=NULL))))

#サンプル名カラムの追加
data_phylum$sample = sub("taxonomy/", "", sub(".kaiju.out", "", data_phylum$file))

#Top10以外はOthersにまとめる
data_phylum_top10 = data_phylum %>% 
                    mutate(taxon_name = ifelse(taxon_name %in% c("unclassified", "cannot be assigned to a (non-viral) phylum"), "unclassified", taxon_name))  %>%  ##unclassifiedの項目を纏める
                    arrange(-percent) %>% arrange(sample) %>%   #相対存在量とサンプル名でソート
                    mutate(taxon_name = ifelse(taxon_name %in% c(head(taxon_name,10), "unclassified"), taxon_name,  "Others")) %>%  #Top10の系統名をリストアップ
                    group_by(taxon_name, sample)  %>%  #系統名とサンプル名でグループ化
                    summarize(percent = sum(percent)) %>%  #新しい系統名で数値を合算
                    arrange(desc(percent))  #見やすいように相対存在量でソート

sample_order = c("DRR267104","DRR267106","DRR267108","DRR267110",
                 "DRR267102","DRR267105","DRR267107","DRR267109")
taxon_order = c(unique(c("unclassified", "Others", rev(data_phylum_top10$taxon_name))))

#作図
#fillのfactorで図示する系統の順番を調整している
g = ggplot(data_phylum_top10, 
            aes (x    = factor(sample, levels=rev(sample_order)),  
                 y    = percent,
                 fill = factor(taxon_name, levels=taxon_order)))
g = g + theme_bw()
g = g + geom_bar(width  = 0.8,
                 stat   = "identity",
                 colour = "black")  #edge color
g = g + xlab(NULL) + ylab("相対存在量 (%)")
g = g + coord_flip()
g = g + guides(fill=guide_legend(reverse = TRUE, nrow = 3))
g = g + scale_y_continuous(expand = c(0,0), limits = c(0,100.1), breaks=seq(0, 100, 20))
g = g + scale_fill_manual(values=rev(c(brewer.pal(8, "Pastel1"),"gray","black")))
g = g + theme(axis.title       = element_text(size = 20),
              axis.text.x      = element_text(size = 20, colour = "black"),
              axis.text.y      = element_text(size = 20, colour = "black"),
              axis.ticks.y     = element_blank(),
              axis.ticks.x     = element_line(size = 1.3),
              axis.line        = element_line(size = 1.3),
              legend.text      = element_text(size = 16),
              legend.title     = element_blank(),
              legend.position  = "bottom",
              plot.margin      = unit(c(0, 0.8, 0, 0.1), "cm"),
              panel.border     = element_rect(color = NA, fill = NA))
plot(g)
