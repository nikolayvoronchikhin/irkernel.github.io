library(devtools)
#install_github('flying-sheep/staticdocs', ref = 'fix-src_highlight')
library(staticdocs)

args <- commandArgs(trailingOnly = TRUE)
package_path <- args[[1]]
site_path <- args[[2]]

make_link <- function(loc, label, pkg = NULL) {
	if (is.null(loc$package))
		sprintf('<a href="%s">%s</a>', loc$file, label)
	else #if (loc$package %in% staticdocs:::builtin_packages)
		sprintf('<a href="http://www.rdocumentation.org/packages/%s/topics/%s">%s</a>', loc$package, loc$topic, label)
}
sd_env <- environment(render_page)
unlockBinding('make_link', sd_env)
assign('make_link', make_link, envir = sd_env)
lockEnvironment(sd_env)

#fix broken Authors@R code
dcf_path <- file.path(package_path, 'DESCRIPTION')
i <- read.dcf(dcf_path)
if ('Authors@R' %in% colnames(i) && !grepl('^c', i[, 'Authors@R'])) {
	colnames(i)[colnames(i) == 'Authors@R'] <- 'Authors'
	write.dcf(i, dcf_path)
}

pkg <- staticdocs:::as.sd_package(package_path)
load_all(pkg)

pkg$sd_path        <- site_path
pkg$site_path      <- site_path
pkg$examples       <- TRUE
pkg$templates_path <- '_templates'
pkg$run_dont_run   <- FALSE
pkg$mathjax        <- TRUE

pkg$topics    <- staticdocs:::build_topics(pkg)
pkg$vignettes <- staticdocs:::build_vignettes(pkg)
pkg$demos     <- staticdocs:::build_demos(pkg)
pkg$readme    <- staticdocs:::readme(pkg)

staticdocs:::build_index(pkg)
staticdocs:::build_reference(pkg)
