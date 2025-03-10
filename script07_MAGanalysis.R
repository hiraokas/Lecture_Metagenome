#==========================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created: 20241117
#  History: 20241201
#  - Making circle phylogenetic tree 
#==========================================================================================

.libPaths("./rlib")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("stringr")) install.packages("stringr")
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!require("treeio")) BiocManager::install("treeio")
if (!require("ggtree")) BiocManager::install("ggtree")

MainTree = read.tree(file = "gtdbtk/MAG/classify/gtdbtk.backbone.bac120.classify.tree")
node_annotation             = data.frame(label  = MainTree$tip.label)
node_annotation$genome_type = ifelse(str_detect(node_annotation$label, "DRR"), "MAG", "GTDB") #ラベル名に「DRR」とあればMAGだと判断する

# 作図
g = ggtree(MainTree, layout = "circular")  %<+% node_annotation +
  # 系統樹の設定
  geom_tippoint(aes(color = genome_type, size = genome_type), shape = 16 , alpha = 0.8) +
  # ノードの色を設定
  scale_color_manual(values = setNames(c("red", "gray"), c("MAG", "GTDB")), name = "") +
  # ノードのサイズを設定
  scale_size_manual( values = setNames(c(4,0.5),         c("MAG", "GTDB"))) +
  # 凡例を表示させる
  guides(color = guide_legend(override.aes = list(alpha=1,size=6), reverse = TRUE), 
         size  = FALSE) +
  # 凡例の体裁と余白を調整
  theme(legend.key.width  = unit(1, "cm"),
        legend.key.height = unit(1, "cm"),
        legend.key        = element_rect(fill = NA, color = NA),
        legend.text       = element_text(size = 24),
        legend.background = element_rect(fill = NA, color = NA),
        legend.position   = c(0.9, 0.5),
        plot.margin       = unit(c(-2,0,-2,-4), "cm"))
plot(g)

# 画像をファイル出力
dev.copy(png, file = "script07_MAGanalysis.png", width = 600, height = 600)
dev.off()