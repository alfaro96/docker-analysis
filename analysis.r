# Analyze the experimental results and generate a report.


# =============================================================================
# Imports
# =============================================================================

# Parse the command line arguments
library(argparser)

# Analyze the experimental results
library(exreport)


# =============================================================================
# Arguments
# =============================================================================

description <- "Analysis of experimental results and report generation."
parser <- arg_parser(description)

arg <- "source"
help <- "Path to the experimental results"
parser <- add_argument(parser, arg, help)

arg <- "destination"
help <- "Path to the rendered file"
parser <- add_argument(parser, arg, help)

arg <- "output"
help <- "Name of the target output variable"
parser <- add_argument(parser, arg, help)

arg <- "rank"
help <- "Optimization strategy of the target output variable"
parser <- add_argument(parser, arg, help)

arg <- "--title"
help <- "Short title for the document"
default <- "Report"
parser <- add_argument(parser, arg, help, default = default)

arg <- "--digits"
default <- 3
help <- "Number of decimal digits for the numeric output"
parser <- add_argument(parser, arg, help, default = default)

arg <- "--alpha"
default <- 0.05
help <- "Significance level used for the testing procedure"
parser <- add_argument(parser, arg, help, default = default)

arg <- "--methods"
default <- ".*"
help <- "Subset of methods to filter"
parser <- add_argument(parser, arg, help, default = default)

arg <- "--problems"
default <- ".*"
help <- "Subset of problems to filter"
parser <- add_argument(parser, arg, help, default = default)

argv <- parse_args(parser)

# Rename the command line arguments for easier reference
source <- argv$source
destination <- argv$destination
output <- argv$output
rankOrder <- argv$rank
title <- argv$title
digits <- argv$digits
alpha <- argv$alpha
methods <- argv$methods
problems <- argv$problems


# =============================================================================
# Main
# =============================================================================

# Format the experimental results to satisfy the corresponding constraints
rowNames <- 1
checkNames <- FALSE
data <- read.csv(source, row.names = rowNames, check.names = checkNames)
data <- cbind(rownames(data), data)
colnames(data)[1] <- "method"

r <- exreport(title)
e <- expCreateFromTable(data, output, title)

split <- ","
methods <- strsplit(methods, split)
problems <- strsplit(problems, split)
methods <- unlist(methods)
problems <- unlist(problems)

# Generate the regular expression to filter the methods and problems
collapse <- "|"
problems <- paste0("(", problems, collapse = collapse, ")")
methods <- paste0("(", methods, collapse = collapse, ")")

rows <- rownames(data)
cols <- colnames(data)

value <- TRUE
methods <- grep(methods, rows, value = value)
problems <- grep(problems, cols, value = value)

subset <- list(method = methods, problem = problems)
e <- expSubset(e, subset)

e <- expInstantiate(e)

tabExp <- tabularExpSummary(e, output, rankOrder, digits = digits)
r <- exreportAdd(r, tabExp)

columns <- 5
freeScale <- TRUE
plotExp <- plotExpSummary(e, output, columns, freeScale)
r <- exreportAdd(r, plotExp)

testM <- testMultiplePairwise(e, output, rankOrder, alpha)
r <- exreportAdd(r, testM)

tabTestM <- tabularTestPairwise(testM)
r <- exreportAdd(r, tabTestM)

testC <- testMultipleControl(e, output, rankOrder, alpha)
r <- exreportAdd(r, testC)

metrics <- c("rank", "pvalue", "wtl")
tabTestC <- tabularTestSummary(testC, metrics)
r <- exreportAdd(r, tabTestC)

plotTestC <- plotRankDistribution(testC)
r <- exreportAdd(r, plotTestC)

showWarnings <- FALSE
dir.create(destination, showWarnings = showWarnings)

target <- "html"
safeMode <- FALSE
visualize <- FALSE
exreportRender(r, destination, target, safeMode, visualize)
