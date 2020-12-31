# Base image https://hub.docker.com/u/rocker/
## This image handles the necessary dependencies for running a ShinyApp and comes with multiple R packages already pre-installed.
FROM rocker/rstudio:latest

RUN apt-get update --fix-missing \
	&& apt-get install -y \
		ca-certificates \
    	libglib2.0-0 \
	 	libxext6 \
	   	libsm6  \
	   	libxrender1 \
		libxml2-dev

# Install python3, virtualenv and the required python packages for twitter trading strategy
RUN apt-get install -y \
		python3-pip \
		python3-dev \
	&& pip3 install virtualenv && \
	 pip3 install openpyxl && \
	 pip3 install tweepy && \
	 pip3 install matplotlib && \
	 pip3 install seaborn && \
	 pip3 install wordcloud && \
	 pip3 install textblob && \
	 pip3 install xlrd && \
	 pip3 install nltk

# Install R development packages and reticulate
RUN R -e "install.packages(c('dplyr','stopwords','shiny', 'quantmod', 'PerformanceAnalytics', 'TTR', 'shinycssloaders','shinyjs', 'shinybusy', 'reticulate', 'remotes'))"

# Load all the files of the app to the image
COPY ./app.R /home/rstudio/
COPY ./modules /home/rstudio/modules
COPY ./data /home/rstudio/data
COPY ./.Rprofile /home/rstudio


# Adding permissions of rstudio
RUN chown -R rstudio /home/rstudio/modules
RUN chown -R rstudio /home/rstudio/data








