#/*******************************************************************************************************************************
  # Program: 			MLmain.R
  # Purpose: 			Main file for Malaria Chapter.  
  #               The main file will call other R files that will produce the ML indicators and produce tables.
  # Data outputs:	coded variables and table output on screen and in excel tables.  
  # Author: 			Hilma Nakambale
  # Date last modified:	June 29, 2024 - DHS 2014 Kenya
  # *******************************************************************************************************************************/
  
  #To make DHS and SF packages work in Quest
  Sys.setenv(INCLUDE = "/software/geos/3.8.1/include:/software/gcc/8.4.0/include:/software/proj/7.1.1/include")
Sys.setenv(PKG_CONFIG_PATH = "/software/sqlite/3.27.2/lib/pkgconfig:/software/proj/7.1.1/lib/pkgconfig:/software/gdal/3.1.3-R-4.1.1/lib/pkgconfig")
old_path <- Sys.getenv("PATH")
Sys.setenv(PATH = paste("/software/geos/3.8.1/bin", old_path, sep = ":"))
old_path <- Sys.getenv("PATH")
Sys.setenv(PATH = paste("/software/proj/7.1.1/bin", old_path, sep = ":"))
old_path <- Sys.getenv("PATH")
Sys.setenv(PATH = paste("/software/gdal/3.1.3-R-4.1.1/bin", old_path, sep = ":"))
install.packages("sf", repos="https://cloud.r-project.org/")

# ***************************************************************************************************************************************/

rm(list = ls(all = TRUE))
#Install libraries
library(microbenchmark)
library(rdhs)
library(httr)
library(data.table)
library(jsonlite)
library(tidyverse)
library(DT)
library(sf)
library(haven)
library(DHS.rates)
library(tools)
library(dplyr)
library(naniar) #to replace values with NA
library(sjlabelled)
library(expss)
library(xlsx)
library(stringr)   # for the rename (str_replace_all) function
library(here)

 ##login
set_rdhs_config(email = "hnakambale@gmail.com",
                project = "Malaria Project_HN",
                config_path = "rdhs.json",
                password_prompt = TRUE,
                global = FALSE)
1

# Authenticate and check the configuration
config <- get_rdhs_config()
print(config)

# the configurations are then assigned to the client object to invoke it later for all the functions
client_Hilma <- client_dhs(config)
client_Hilma

#Obtaining all country IDS
ids <- dhs_countries(returnFields = c("CountryName", "DHS_CountryCode", "SubregionName"))
print(ids)

# List available datasets - DHS and MIS
kenya_surveys <- dhs_surveys(countryIds = "KE", surveyType = c("DHS"))
print(kenya_surveys)

# List of files to download
data_files <- c("KEHR72FL", "KEIR72FL", "KEPR72FL", "KEKR72FL")

# Get the dataset metadata for Kenya surveys
datasets <- dhs_datasets(countryIds = "KE")
print(datasets)

# define/Filter datasets to include only the specified files
filtered_datasets <- datasets %>%
  filter(grepl(paste(data_files, collapse = "|"), FileName))
print(filtered_datasets)

# download datasets
downloaded_data <- get_datasets(filtered_datasets$FileName)
print(downloaded_data)

# Convert .rds to .dta
for (file in downloaded_data) {
  rds_file <- file
  dta_file <- sub(".rds", ".dta", rds_file)
  data <- readRDS(rds_file)
  write_dta(data, dta_file)
  print(paste("Saved", dta_file))
}

# Save the .dta files in the current working directory - do this step (overwrite = TRUE) if files deleted i.e., for Git  space hub
#for (file in downloaded_data) {
# rds_file <- file
# dta_file <- sub(".rds", ".dta", rds_file)
#data <- readRDS(rds_file)
#write_dta(data, dta_file)
# file.copy(dta_file, ".", overwrite = TRUE)
# print(paste("Saved", dta_file, "/home/ani7465/Mymalariaproject1"))
#}

# Paths to the .dta files (adjust the paths as needed)
dta_files <- c("~/.cache/rdhs/datasets/KEHR72FL.dta",
               "~/.cache/rdhs/datasets/KEIR72FL.dta",
               "~/.cache/rdhs/datasets/KEKR72FL.dta",
               "~/.cache/rdhs/datasets/KEPR72FL.dta")

# Read each .dta file and store them in a list
data_list <- lapply(dta_files, read_dta)

# Assign names to the list elements for easier reference
names(data_list) <- c("KEHR72FL", "KEIR72FL", "KEKR72FL", "KEPR72FL")

data_list

## Define datasets
# HR Files
HRdatafile <- data_list$KEHR72FL
# PR Files
PRdatafile <- data_list$KEPR72FL
# IR Files
IRdatafile <- data_list$KEIR72FL
# KR Files
KRdatafile <- data_list$KEKR72FL

# Print the first few rows of each dataset
print(head(HRdatafile))
print(head(IRdatafile))
print(head(KRdatafile))
print(head(PRdatafile))

# Path for malaria chapter 12. This is also where the data is stored
chap <- "/home/ani7465/Mymalariaproject1/chap12"

# Read the HR dataset for the Kenya surveys
HRdata <- read_dta(dta_files[1])

# open IR dataset
IRdata <- read_dta(dta_files[2])

# open KR dataset
KRdata <- read_dta(dta_files[3])

# open KR dataset
PRdata <- read_dta(dta_files[4])

#Check head
print(head(HRdata))
print(head(IRdata))
print(head(KRdata))
print(head(PRdata))

# HR file variables ############################################################

# open HR dataset
HRdata <- read_dta(dta_files[1])

# Purpose: Code household net indicators
source(here(paste0(chap,"/ML_NETS_HH.R")))

# Purpose: will produce the tables for ML_NETS_HH.do file indicators
source(here(paste0(chap,"/ML_tables_HR.R")))

# Purpose: Code indicators for Use of existing ITNs
source(here(paste0(chap,"/ML_EXISTING_ITN.R"))) 

# Purpose: code source of mosquito net
source(here(paste0(chap,"/ML_NETS_source.R"))) 

# IR file variables ############################################################

# open IR dataset
IRdata <- read_dta(dta_files[2])

# Purpose: Code malaria IPTP indicators
source(here(paste0(chap,"/ML_IPTP.R")))

# Purpose: produce the tables for indicators produced from the above do file
source(here(paste0(chap,"/ML_tables_IR.R")))

# KR file variables ############################################################

# open KR dataset
KRdata <- read_dta(dta_files[3])

# Purpose: Code indicators on fever, fever care-seeking, and antimalarial drugs
source(here(paste0(chap,"/ML_FEVER.R")))

# Purpose: produce the tables for indicators produced from the above do file
source(here(paste0(chap,"/ML_tables_KR.R")))

# PR file variables ############################################################

# open PR dataset
PRdata <- read_dta(dta_files[4])

# Purpose: Code net use in population
source(here(paste0(chap,"/ML_NETS_use.R")))

# Purpose: Code anemia and malaria testing prevalence in children under 5
source(here(paste0(chap,"/ML_BIOMARKERS.R")))

# Purpose: produce the tables for indicators produced from the above two do files.
######source(here(paste0(chap,"/ML_tables_PR.R")))

# Purpose: code population access to ITN
# open HR dataset
HRdata <- read_dta(dta_files[1])
source(here(paste0(chap,"/ML_NETS_access.R")))
##############################################################################################################

# Display the first few rows of the column
colnames(KRdatafile)
head(HRdatafile$ml10)
# Get the full name (label) of a specific column
label <- attr(KRdatafile$ml1, "label")
print(label)

colnames(PRdatafile)

# Extract the labels
labels <- sapply(HRdatafile, function(x) attr(x, "label"))

# Convert to a data frame for easy searching
labels_df <- data.frame(column_code = names(labels), column_label = unname(labels), stringsAsFactors = FALSE)

# Define the target label
target_label <- "source of net"

# Function to perform case-insensitive matching and handle extra spaces
match_label <- function(label, target) {
  tolower(trimws(label)) == tolower(trimws(target))
}

# Search for the column code by label
column_code <- labels_df$column_code[sapply(labels_df$column_label, match_label, target = target_label)]

# Check if no match is found and suggest close matches
if (length(column_code) == 0) {
  print("No exact match found. Here are the available labels for review:")
  print(labels_df)
} else {
  print(column_code)
}

variable_names <- colnames(HRdatafile)

# Filter variable names that start with "HML"
hml_variables <- variable_names[grep("^HML", variable_names)]

# If labels are stored as attributes (common in haven-loaded datasets):
if (any(grepl("label", names(attributes(df)[[1]])))) {
  hml_labels <- sapply(hml_variables, function(x) attr(df[[x]], "label"))
  # Create a data frame to display variable names and labels
  hml_df <- data.frame(Variable = hml_variables, Label = hml_labels, stringsAsFactors = FALSE)
} else {
  # If labels are not available, just list variable names
  hml_df <- data.frame(Variable = hml_variables, Label = NA, stringsAsFactors = FALSE)
}

# Print the data frame
print(hml_df)










df <- read.csv("your_dataset.csv")

# List all variable names
variable_names <- HRdatafile

# Search for variables with specific keywords in their names or labels
search_terms <- c("place", "obtained")
matching_variables <- variable_names[sapply(variable_names, function(x) any(grepl(paste(search_terms, collapse = "|"), x, ignore.case = TRUE)))]
print(matching_variables)


df <- as.data.frame(HRdatafile)

# Extract variable names
variable_names <- names(df)

# Filter variable names that start with "HML"
hml_variables <- variable_names[grep("^HML", variable_names)]

# If labels are stored as attributes (common in haven-loaded datasets):
if (any(grepl("label", names(attributes(df)[[1]])))) {
  hml_labels <- sapply(hml_variables, function(x) attr(df[[x]], "label"))
  # Create a data frame to display variable names and labels
  hml_df <- data.frame(Variable = hml_variables, Label = hml_labels, stringsAsFactors = FALSE)
} else {
  # If labels are not available, just list variable names
  hml_df <- data.frame(Variable = hml_variables, Label = NA, stringsAsFactors = FALSE)
}

# Print the data frame
print(hml_df)




# Load the dataset (adjust based on your file type)
df <- KRdatafile

# Extract variable names
variable_names <- names(df)

# Extract variable labels if they exist
variable_labels <- sapply(variable_names, function(x) attr(df[[x]], "label"))

# Replace NULL labels with "No Label"
variable_labels[is.null(variable_labels)] <- "No Label"

# Create a data frame to display variable names and labels
variable_df <- data.frame(Variable = variable_names, Label = variable_labels, stringsAsFactors = FALSE)

# Print the data frame
print(variable_df)

# Extract variable names
variable_names <- names(df)

# Extract variable labels if they exist
variable_labels <- sapply(variable_names, function(x) attr(df[[x]], "label"))

# Combine variable names and labels into a data frame
variable_df <- data.frame(Variable = variable_names, Label = variable_labels, stringsAsFactors = FALSE)

# Filter for variables related to nets or ITNs
keywords <- c("quinine iv")
net_related_df <- variable_df[apply(variable_df, 1, function(row) any(grepl(paste(keywords, collapse = "|"), row, ignore.case = TRUE))), ]

# Print the filtered data frame
print(net_related_df)
















