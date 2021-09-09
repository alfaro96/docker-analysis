# A simple example script to install the packages provided by the command line arguments

install.packages(commandArgs(trailingOnly = TRUE), repos = "https://cran.rstudio.com")
