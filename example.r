# Format and export the experimental results.


# =============================================================================
# Libraries
# =============================================================================

# Parse the command line arguments
library(argparser)

# Format the experimental results
library(dplyr)
library(tidyr)

# Read the experimental results
library(readr)
library(purrr)

# Remove the file extensions
library(stringr)

# Export the tabular information
library(xtable)


# =============================================================================
# Arguments
# =============================================================================

description <- "Format and exportation of experimental results."
parser <- arg_parser(description)

arg <- "source"
help <- "Path to the experimental results"
parser <- add_argument(parser, arg, help)

arg <- "destination"
help <- "Path to the tables"
parser <- add_argument(parser, arg, help)

arg <- "output"
help <- "Name of the target output variable"
parser <- add_argument(parser, arg, help)

arg <- "rank"
help <- "Optimization strategy of the target output variable"
parser <- add_argument(parser, arg, help)

arg <- "--digits"
default <- 3
help <- "Number of decimal digits for the numeric output"
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
rank_order <- argv$rank
digits <- argv$digits
problems <- argv$problems
methods <- argv$methods

# Get the optimization strategy function for calling
rank_order <- get(rank_order)


# =============================================================================
# Functions
# =============================================================================

read_file <- function(file)
{
    data <- read_csv(file)

    # Remove the file extension to get the method name instead of the file name
    pattern <- ".csv"
    path <- str_remove_all(file, pattern)

    # Create a column with the file path to extract the method and problem
    data <- mutate(data, path = path)

    sep <- .Platform$file.sep
    columns <- c("results", "algorithm", "problem", "method")
    data <- separate(data, path, columns, sep = sep)

    data <- select(data, problem, method, output)

    data
}


format_outputs <- function(outputs)
{
    outputs <- round(outputs, digits = digits)
    format <- paste0("%.", digits, "f")

    sprintf(format, outputs)
}


get_mean_table <- function(data)
{
    mean <- select(data, problem, method, mean)
    mean <- spread(mean, problem, mean)

    mean
}


get_tabular_table <- function(data)
{
    tabular <- mutate(data, tex = get_tex_column(mean, sd))
    tabular <- select(tabular, problem, method, tex)
    tabular <- spread(tabular, problem, tex)

    tabular
}


get_tex_column <- function(mean, sd)
{
    # Obtain the best means to highlight the tabular cells
    mask <- mean == rank_order(mean)

    tex <- ifelse(mask, make_bold(mean, sd), make_normal(mean, sd))
    
    factor(tex)
}


make_bold <- function(mean, sd) paste("$", "\\bf", mean, "\\pm", sd, "$")


make_normal <- function(mean, sd) paste("$", mean, "\\pm", sd, "$")


# =============================================================================
# Main
# =============================================================================

split <- ","
methods <- strsplit(methods, split)
problems <- strsplit(problems, split)
methods <- unlist(methods)
problems <- unlist(problems)

paths <- file.path("results", "*", "*", "*.csv")
paths <- Sys.glob(paths)

# Generate the regular expression to filter the methods and problems
collapse <- "|"
problems <- paste0("(", problems, collapse = collapse, ")")
methods <- paste0("(", methods, collapse = collapse, ")")
pattern <- file.path("results", ".*", problems, methods)

value <- TRUE
paths <- grep(pattern, paths, value = value)

# Turn off the reader messages
options(readr.num_columns = 0)

data <- map_df(paths, read_file)

functions <- list(mean = "mean", sd = "sd")
data <- group_by(data, method, problem)
data <- summarise_all(data, functions)

# Format the numeric outputs to use a fixed width for the values
data <- mutate(data, across(where(is.numeric), format_outputs))

destination <- file.path(destination, output)
showWarnings <- FALSE
recursive <- TRUE
dir.create(destination, showWarnings, recursive)

mean <- get_mean_table(data)
csv_destination <- file.path(destination, "mean.csv")
write_csv(mean, csv_destination)

tabular <- get_tabular_table(data)
tex_destination <- file.path(destination, "tabular.tex")
rownames <- FALSE

# Do not sanitize the text to use math mode
sanitize_function <- I

print(xtable(tabular),
      file = tex_destination,
      include.rownames = rownames,
      sanitize.text.function = sanitize_function)
