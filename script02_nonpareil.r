#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241104
#  - ref: http://nonpareil.readthedocs.io/en/latest/curves.html
#============================================================================================================

.libPaths("./rlib")  #Rライブラリの格納場所を設定
if (!require("Nonpareil"))    install.packages("Nonpareil")
if (!require("RColorBrewer")) install.packages("RColorBrewer")

InputFilename_list=c("QC/DRR267104.nonpareil.npo",
                     "QC/DRR267106.nonpareil.npo")

plot_nonpareil <- function(input_filename, Color){
    p = Nonpareil.curve(input_filename, plot= TRUE, main = NULL, col=Color,
                        enforce.consistency = TRUE, star = 95, 
                        correction.factor   = TRUE,
                        weights.exp  = NA, skip.model = FALSE,
                        curve.alpha  = 0.7,
                        curve.lwd    = 10,
                        plot.model   = FALSE,
                        model.lwd    = 0,
                        arrow.length =0,
                        xlim     = c(1e+3, 2e+12),
                        cex      = 2,
                        cex.axis = 2.5,
                        cex.main = 3,
                        cex.lab  = 3,
                        yaxt = "n",
                        xlab = "", 
                        ylab = "",
                        plot.dispersion = FALSE,
                        plot.diversity  = FALSE,
                        new = TRUE
                        )
    
    axis(2, las=2, cex.axis  = 2.5, 
         at     = c( 0.2,  0.4,  0.6,  0.8, 0.95,     1), 
         labels = c("20", "40", "60", "80", "95", "100"))
    title(xlab  = "Sequencing effort (bp)", 
          ylab  = "Estimated average coverage (%)", 
          cex.lab  = 3, line = 5)

    predict(p)
    p$diversity

    return(p)   
}

ColorList     = brewer.pal(8, "Set2")
p1  = plot_nonpareil(InputFilename_list[ 1], ColorList[ 1]); par(new=T) 
p2  = plot_nonpareil(InputFilename_list[ 2], ColorList[ 2]); par(new=T) 

p1$label  = "DRR267106"
p2$label  = "DRR267105"

Nonpareil.legend(c(p1, p2 ), 
                 1500, 0.90,
                 pt.cex     = 0.9,
                 pt.lwd     = 0.9,
                 box.lty    = 1,
                 box.lwd    = 3,
                 cex        = 1.5,
                 y.intersp  = 0.6,
                 x.intersp  = 0.3,
                 text.width = 0.6
                 )

