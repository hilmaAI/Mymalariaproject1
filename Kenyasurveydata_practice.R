##Subnational data KE
library(microbenchmark)
library(rdhs)
library(httr)
library(data.table)
library(jsonlite)
library(tidyverse)
library(DT)
library(sf)

##login
set_rdhs_config(email = "hnakambale@gmail.com",
                project = "Malaria Project_HN",
                config_path = "rdhs.json",
                password_prompt = TRUE,
                global = FALSE)

# Authenticate and check the configuration
config <- get_rdhs_config()
print(config)

#Obtaining country IDS
ids <- dhs_countries(returnFields = c("CountryName", "DHS_CountryCode", "SubregionName"))
print(ids)

# List available datasets - DHS and MIS
surveys <- dhs_surveys(countryIds = "KE", surveyType = c("DHS", "MIS"))
print(surveys)

# Filter surveys for Kenya
kenya_surveys <- surveys %>% filter(str_detect(SurveyId, "KE"))
print(kenya_surveys)

# List of files to download
data_files <- c("KEHR72DT.ZIP", "KEKR72DT.ZIP", "KEPR72DT.ZIP", "KEIR72.ZIP",
                "KEHR7ADT.ZIP", "KEIR7ADT.ZIP", "KEKR7ADT.ZIP", "KEPR7ADT.ZIP",
                "KEHR81DT.ZIP", "KEIR81DT.ZIP", "KEKR81DT.ZIP", "KEPR81DT.ZIP",
                "KEGR8BDT.ZIP", "KEHR8BDT.ZIP", "KEIR8BDT.ZIP", "KEKR8BDT.ZIP",
                "KENR8BDT.ZIP", "KEPR8BDT.ZIP")
print(data_files)

# Get the dataset metadata for Kenya surveys
datasets <- dhs_datasets(countryIds = "KE")

# Filter datasets to include only the specified files
filtered_datasets <- datasets %>%
  filter(grepl(paste(data_files, collapse = "|"), FileName))
print(filtered_datasets)

# Download the selected datasets
for (i in 1:nrow(filtered_datasets)) {
  get_datasets(filtered_datasets[i, ])
}

##############################################################################################Download datasets

# Get the dataset metadata for Kenya surveys
datasets <- dhs_datasets(surveyIds = kenya_surveys$SurveyId)

# Print dataset details to find the appropriate datasets for malaria
print(datasets)





##############################################

# the first time this will take a few seconds 
microbenchmark::microbenchmark(dhs_datasets(surveyYearStart = 1986),times = 1)
#> Unit: milliseconds
#>                                  expr     min      lq    mean  median      uq
#>  dhs_datasets(surveyYearStart = 1986) 46.3744 46.3744 46.3744 46.3744 46.3744
#>      max neval
#>  46.3744     1

# after caching, results will be available instantly
microbenchmark::microbenchmark(dhs_datasets(surveyYearStart = 1986),times = 1)
#> Unit: milliseconds
#>                                  expr      min       lq     mean   median
#>  dhs_datasets(surveyYearStart = 1986) 1.410894 1.410894 1.410894 1.410894
#>        uq      max neval
#>  1.410894 1.410894     1
#

