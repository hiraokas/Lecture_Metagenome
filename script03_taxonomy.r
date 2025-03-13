#==========================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created: 20241110
#  History: 20250310
#==========================================================================================

.libPaths("./rlib")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("ggplot2"))      install.packages("ggplot2")
if (!require("tidyverse"))    install.packages("tidyverse")

# データセットの読み込み、結合
files = list.files("taxonomy/", pattern="phylum.tsv", full.names = T)
data_phylum = do.call(rbind, lapply(files, function(x)(read.table(x, header = T, sep = "\t", row.names = NULL))))

# サンプル名カラムの追加
data_phylum$sample = sub("taxonomy/", "", sub(".kaiju.out", "", data_phylum$file))

# Top10以外はOthersにまとめる
data_phylum_top10 = data_phylum %>% 
                    # 2つの系統名をunclassifiedに変更纏める
                    mutate(taxon_name = ifelse(taxon_name %in% c("unclassified", "cannot be assigned to a (non-viral) phylum"), "unclassified", taxon_name))  %>%  
                    # 相対存在量とサンプル名でソート
                    arrange(-percent) %>% arrange(sample) %>%
                    # Top10とunclassified以外の系統名をOthersに変更
                    mutate(taxon_name = ifelse(taxon_name %in% c(head(taxon_name,10), "unclassified"), taxon_name, "Others")) %>%  
                    # 系統名とサンプル名でグループ化
                    group_by(taxon_name, sample)      %>%  
                    # 新しい系統名で数値を合算
                    summarize(percent = sum(percent)) %>%  
                    # 見やすいように相対存在量でソート
                    arrange(desc(percent))  

sample_order = c("DRR267104", "DRR267106", "DRR267108", "DRR267110",
                 "DRR267102", "DRR267105", "DRR267107", "DRR267109")
taxon_order = unique(c("unclassified", "Others", rev(data_phylum_top10$taxon_name)))

# 作図
g = ggplot(data_phylum_top10, 
           aes (x    = factor(sample,     levels = rev(sample_order)),  
                y    = percent,
                fill = factor(taxon_name, levels = taxon_order))) +
  # 棒グラフの設定
  geom_bar(width = 0.8, stat = "identity", color = "black") +
  # テーマを白にする
  theme_bw() + 
  # x軸が縦に、y軸が横になるように回転
  coord_flip() +
  # 軸ラベルの設定
  xlab(NULL) + ylab("相対存在量 (%)") +
  # 横軸を0-100％に設定し、20％ごとにラベルを入れる
  scale_y_continuous(expand = c(0,0), limits = c(0,100.1), breaks = seq(0, 100, 20)) +
  # 各系統に色を付ける
  scale_fill_manual(values = rev(c(brewer.pal(8, "Pastel1"), "gray", "black"))) +
  # 凡例を横3行表示にして並び順を調整
  guides(fill = guide_legend(reverse = TRUE, nrow = 4)) +
  # 軸や文字の体裁、余白を調整
  theme(axis.title      = element_text(size = 30),
        axis.text.x     = element_text(size = 26, color = "black"),
        axis.text.y     = element_text(size = 26, color = "black"),
        axis.ticks.y    = element_blank(),
        axis.ticks.x    = element_line(size = 1.3),
        axis.line       = element_line(size = 1.3),
        legend.text     = element_text(size = 20),
        legend.title    = element_blank(),
        legend.position = "bottom",
        plot.margin     = unit(c(1, 2, 0, 1), "lines"),
        panel.border    = element_rect(color = NA, fill = NA))
plot(g)

# 画像をファイル出力
ggsave(plot = g, "script03_taxonomy.png", dpi = 600, width = 10, height = 6)
