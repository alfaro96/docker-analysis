FROM jupyter/datascience-notebook

COPY install.r format.ipynb analysis.ipynb execute.bash /home/jovyan/

RUN Rscript install.r argparser exreport

ENTRYPOINT ["bash", "execute.bash"]
