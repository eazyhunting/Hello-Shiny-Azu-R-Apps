FROM rocker/shiny:latest

# Install shiny package
RUN R -e "install.packages(c('shiny', 'ggplot2', 'dplyr'), repos='https://cloud.r-project.org/')"

# Copy the app into the Shiny server's directory
COPY ./app /srv/shiny-server/

# Switch to a non-root user
# RUN useradd -r shiny && chown -R shiny /srv/shiny-server
# USER shiny

# Set the proper permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose the Shiny server port
EXPOSE 3838

# Start the Shiny server
CMD ["/usr/bin/shiny-server"]
