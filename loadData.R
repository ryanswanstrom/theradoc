# Theradoc Screen Scraper Utility
# Colin A. White | Clinical Intelligence | Sept 2014

# Set a working directory
setwd("C:\\Theradoc")
# Load all my helper functions
source("getData.R")

# Get and clean the reports
cauti <- numDen(getData(13640, "cauti")) 

clasbi <- numDen(getData(13660, "clasbi"))

ssicolon <- numDen(getData(13680, "ssicolon"))

ssihyst <- numDen(getData(13681, "ssihyst"))

# CAST and row bind into a form the RODBC can handle 
results <- as.data.frame(rbind(cauti, clasbi, ssicolon, ssihyst))

# Load ODBC library
library(RODBC)

# Create the connection string
dbhandle <- odbcDriverConnect('driver={SQL Server};
                              server=AHDC389;
                              database=ExecInsight;
                              trusted_connection=true')

# Do the SQL insert/update
sqlUpdate(dbhandle, results, table="theradoc" )

# Close the connection
close(dbhandle)