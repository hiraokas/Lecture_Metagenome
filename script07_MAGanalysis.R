#==========================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Forked:  20241117
#  History: 20241120
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
node_annotation$genome_type = ifelse(str_detect(node_annotation$label, "DRR"), "MAG", "GTDB")

g = ggtree(MainTree, layout = "circular")  %<+% node_annotation 
g = g + geom_tippoint(aes(color = genome_type, size = genome_type), shape = 16 , alpha = 0.8) 
g = g + scale_color_manual(values = setNames(c("red", "gray"), c("MAG", "GTDB")), name = "")
g = g + scale_size_manual( values = setNames(c(4,0.5),         c("MAG", "GTDB")))
g = g + guides(color = guide_legend(override.aes = list(alpha=1,size=6), reverse = TRUE), 
               size  = FALSE)
g = g + theme(legend.key.width  = unit(1, "cm"),
              legend.key.height = unit(1, "cm"),
              legend.title      = element_text(face = "bold", size   = 22),
              legend.text       = element_text(size = 18),
              legend.position   = 'right',
              legend.direction  = "vertical",
              plot.margin       = unit(c(0,0,0,0), "cm"))
plot(g)

