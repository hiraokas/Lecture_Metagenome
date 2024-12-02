#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241201
#  - ref: http://nonpareil.readthedocs.io/en/latest/curves.html
#============================================================================================================

.libPaths("./rlib")
if (!require("Nonpareil"))    install.packages("Nonpareil")
if (!require("RColorBrewer")) install.packages("RColorBrewer")

plot_nonpareil <- function(input_filename, Color){
    p = Nonpareil.curve(input_filename, plot= TRUE, main = NULL, col = Color,
                        enforce.consistency = TRUE, star = 95, correction.factor   = TRUE,
                        weights.exp = NA, skip.model = FALSE,
                        curve.alpha = 0.7, curve.lwd = 10,
                        xlim = c(1e+3, 2e+12), ylim = c(0, 1),
                        xaxt = "n", yaxt = "n", xlab = NA, ylab = NA,
                        plot.model = TRUE, plot.dispersion = FALSE, plot.diversity  = FALSE,
                        cex.axis = 1.5, new = TRUE)
    axis(1, lwd=3, cex.axis = 1.5)
    axis(2, lwd=3, cex.axis = 1.5, 
         at     = c(0,   0.2,  0.4,  0.6,  0.8, 0.95,     1), 
         labels = c("0", "20", "40", "60", "80", "95", "100"))
    title(xlab  = "配列データサイズ (bp)", 
          ylab  = "メタゲノムカバレッジ (%)", 
          main = NA, cex.lab  = 2, line = 3.5)
    return(p)   
}

InputFilename_list=c("nonpareil/DRR267104.npo",
                     "nonpareil/DRR267106.npo",
                     "nonpareil/DRR267108.npo",
                     "nonpareil/DRR267110.npo")

par(mar=c(5,5.5,1.5,1))
ColorList = brewer.pal(8, "Set2")
p1 = plot_nonpareil(InputFilename_list[1], ColorList[1]); par(new=T); p1$label = "DRR267104"
p2 = plot_nonpareil(InputFilename_list[2], ColorList[2]); par(new=T); p2$label = "DRR267106" 
p3 = plot_nonpareil(InputFilename_list[3], ColorList[3]); par(new=T); p3$label = "DRR267108" 
p4 = plot_nonpareil(InputFilename_list[4], ColorList[4]); par(new=T); p4$label = "DRR267110" 

Nonpareil.legend(c(p1, p2, p3, p4), 2000, 0.85,
                 box.lty = 1, box.lwd = 3, cex = 1.2,
                 y.intersp = 1, x.intersp = 0.3,
                 text.width = 2.2)

#カバレッジ値の表示
predict(p1) * 100
predict(p2) * 100
predict(p3) * 100
predict(p4) * 100
