#==========================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created: 20241120
#  History: 20250313
#==========================================================================================

.libPaths("./rlib")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("ggplot2"))      install.packages("ggplot2")
if (!require("tidyverse"))    install.packages("tidyverse")

# データセットの読み込み、結合
files = list.files("annotation/", pattern = "_eggnog.category.tsv", full.names = T)
cog_count = do.call(rbind, lapply(files, function(x)(read.table(x, header = F, sep = "\t", row.names = NULL))))
colnames(cog_count) = c("sample", "category", "count")
cog_count = cog_count[cog_count$category != "-",]

# サンプルあたりの遺伝子数リストを与えて、相対存在率を算出
sample_CDSnum = data.frame("DRR267104" = 429344322,
                           "DRR267106" = 471502430,
                           "DRR267108" = 373133956,
                           "DRR267110" = 413969472,
                           "DRR267102" = 7514379,
                           "DRR267105" = 5614684,
                           "DRR267107" = 5139661,
                           "DRR267109" = 5398201)
cog_data = cog_count %>% 
           mutate(CDSnum = as.numeric(sample_CDSnum[sample])) %>% 
           mutate(ratio = count / CDSnum)

# 各機能カテゴリの詳細
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

# 作図
g = ggplot(cog_data, 
           aes (x    = factor(category, levels = rev(LETTERS)), # LETTERSはアルファベット文字の配列である
                y    = ratio * 100,
                fill = factor(sample,   levels = rev(colnames(sample_CDSnum))))) +
  # 棒グラフを設定
  geom_bar(width    = 0.8, stat = "identity",
           position = "dodge", color   = "black") +
  # テーマを白にする
  theme_bw() + 
  # x軸が縦に、y軸が横になるように回転
  coord_flip() +
  # 軸ラベルの設定
  xlab("機能カテゴリ ID") + ylab("相対存在量 (%)") +
  # y軸の始点を軸線に揃える
  scale_y_continuous(expand = c(0,0)) +
  # 凡例を縦1列表示にして並び順を調整
  guides(fill = guide_legend(reverse = TRUE, ncol = 1)) +
  # 軸や文字の体裁、余白を調整
  theme(axis.title   = element_text(size = 30),
        axis.text.x  = element_text(size = 30, color = "black"),
        axis.text.y  = element_text(size = 24, color = "black"),
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_line(size = 1.3),
        axis.line    = element_line(size = 1.3),
        legend.text  = element_text(size = 24),
        legend.title = element_blank(),
        panel.border = element_rect(color = NA, fill = NA))
plot(g)

# 画像をファイル出力
ggsave(plot = g, "script05_geneFunctionalAnnotation.png", dpi = 600, width = 8, height = 8)
