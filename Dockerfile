FROM r-base

# Install the libraries to format, export and analyze the experimental results
RUN install.r argparser dplyr tidyr tibble readr xtable exreport

# Copy the files to format, export and analyze the experimental results
COPY . /usr/local/src

ENTRYPOINT ["Rscript"]
