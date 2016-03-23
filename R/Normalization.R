#' @export
calc_fpkm <- function(counts, gene2length) {
        order = match(rownames(counts),gene2length[,1]);
        norm = counts[!is.na(order),]
        order = order[!is.na(order)]
        weighted_sum_lengths = colSums(norm*as.numeric(gene2length[order,2]))
        fpkms = t(t(norm)/weighted_sum_lengths)*10^9
        return(fpkms)
}

#' @export
calc_cpm <- function(counts, spikes) {
        totreads = colSums(counts[-spikes,]);
        cpms = t(t(counts)/totreads)*1000000;
        return(cpms);
}

#' @export
calc_SF <- function (counts, spikes, locfunc = median) {
	loggeomeans <- rowMeans(log(counts[-spikes,]))
	size_factor = apply(counts[-spikes,], 2, function(cnts) exp(locfunc((log(cnts) -
	loggeomeans)[is.finite(loggeomeans)])))
	return(t(t(counts)/size_factor))
}

#' @export
calc_UQ <- function (counts, spikes) {
        UQ <- function(x){quantile(x[x>0],0.75)};
        uq = unlist(apply(counts[-spikes,],2,UQ));
        normfactor = (uq/median(uq)) ;
        UQnorm = t(t(counts)/normfactor);
        return(UQnorm);
}

#' @export
filter_genes <- function(expr_mat) {
	filter <- apply(expr_mat, 1, function(x) length(x[x>5])>=2)
	filtered <- expr_mat[filter,]
	return(filtered);
}

#' @export
QC_histogram <- function(score, name="Score") {
	mu = mean(score);
	sigma = sd(score);
	hist(score, col="grey75", xlab=name, main="", prob=TRUE)
	curve(dnorm(x, mean=mu, sd=sigma), add=TRUE);
}

#' @export
calc_cell_RLE <- function(expr_mat) {
	 out = t(apply(expr_mat , 1, function(x){
                        if(median(unlist(x)) > 0) {
                                log((x+1)/(median(unlist(x))+1))/log(2)
                        } else {
                                rep(NA, times=length(x))
                        }
                }))
	cell_med = apply(out, 2, median, na.rm=T)
	return(cell_med)
}

#' @export
plot_RLE <- function(expr_mat, groups=colnames(expr_mat), colour="grey75") {
	out = t(apply(expr_mat , 1, function(x){
                        if(median(unlist(x)) > 0) {
                                log((x+1)/(median(unlist(x))+1))/log(2)
                        } else {
                                rep(NA, times=length(x))
                        }
                }))
	colnames(out) = colnames(expr_mat);
	if (length(unique(groups)) == length(expr_mat[1,])) {
		boxplot(out, col=colour, xlab="Cell", ylab="Relative Log Expression", las=2);
		abline(h=0)
		invisible(out);
	} else {
		cell_med = apply(out, 2, median, na.rm=T)
		boxplot(cell_med~groups, col=colour, xlab="Group", ylab="Relative Log Expression", las=2, pars=list(outcol="white"))
		stripchart(cell_med ~ groups, vertical = TRUE, method = "jitter",
        		pch = 21, col = "black", bg = "darkgoldenrod1", add = TRUE)
		abline(h=0)
		invisible(cell_med);
	}
}

#' @export
plot_PCA <- function(expr_mat, groups1=rep(1, times=length(expr_mat[1,])), groups2=rep(1, times=length(expr_mat[1,]))) {
	if (length(unique(groups1)) > 6 | length(unique(groups2)) > 6) {stop("Too many groups to be displayed")}
	my_colour_palette = c("chartreuse4", "darkmagenta", "blue2", "darkorange1", "red", "cyan")
	my_pch_palette = c(16, 17, 15, 1, 2, 0)
	pca = prcomp(t(expr_mat), center=TRUE, retx=TRUE, scale=TRUE)
	perc_var1=round((pca$sdev[1]^2/sum(pca$sdev^2))*100)
	perc_var2=round((pca$sdev[2]^2/sum(pca$sdev^2))*100)
	plot(pca$x[,1], pca$x[,2], col=my_colour_palette[as.factor(groups1)], pch=my_pch_palette[as.factor(groups2)], xlab = paste("PC1 (",perc_var1,"%)",sep=""), ylab = paste("PC2 (",perc_var2,"%)",sep=""))
}

#' @export
plot_tSNE <- function(expr_mat, groups1=rep(1, times=length(expr_mat[1,])), groups2=rep(1, times=length(expr_mat[1,])), initial_dims=round(length(expr_mat[1,])/20+0.5), perplexity = round(length(expr_mat[1,])/10)){
	if (length(unique(groups1)) > 6 | length(unique(groups2)) > 6) {stop("Too many groups to be displayed")}
	my_colour_palette = c("chartreuse4", "darkmagenta", "blue2", "darkorange1", "red", "cyan")
	my_pch_palette = c(16, 17, 15, 1, 2, 0)
	tSNE = tsne(expr_mat, initial_dims=initial_dims, perplexity = perplexity);
	plot(tSNE[,1], tSNE[,2], xlab="Dimension 1", ylab="Dimension 2")
}