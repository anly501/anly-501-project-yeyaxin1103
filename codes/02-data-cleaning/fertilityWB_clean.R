library(tidyverse)
library(dplyr)

# -------- Fertility Rate (births per woman) World Bank ----------------- #
## --- FertilityRate_Raw.csv --- #

fertDF <- read.csv('anly-501-project-yeyaxin1103/data/00-raw-data/Downloaded_Data/FertilityRate_WB/FertilityRate_Raw.csv', header = FALSE)
## remove first few extra rows
fertDF <- fertDF[-c(1,2),]
## make first row column names and remove first row
colnames(fertDF) <- fertDF[1,]
fertDF <- fertDF[-c(1),]
## remove white space from column names
names(fertDF) <- gsub(" ", "_", names(fertDF))
## remove columns: Indicator_Name, Indicator_Code, 2021, NA
fertDF <- fertDF[, -which(names(fertDF) %in% c("Indicator_Name", "Indicator_Code", "2021", "NA"))]
## melting (1960 - 2020)
fertDF <- fertDF %>% pivot_longer(cols = -c(Country_Name, Country_Code), 
                                  names_to = 'year', values_to = 'FertilityRate')
## keep 3 digits after the decimal point for the new column FertilityRate
fertDF <- fertDF %>% mutate(across(where(is.numeric), ~ round(., digits = 3)))
## check if there are NA values in every column
any(is.na(fertDF$Country_Name))
any(is.na(fertDF$Country_Code))
any(is.na(fertDF$Country_Code))
any(is.na(fertDF$FertilityRate))
## get the country code where it contains NA
unique((fertDF[is.na(fertDF$FertilityRate),])$Country_Name)


## --- Fertility_CountryInfo.csv --- #

fert_countryInfo <- read.csv('anly-501-project-yeyaxin1103/data/00-raw-data/Downloaded_Data/FertilityRate_WB/Fertility_CountryInfo_Raw.csv', header = TRUE)
## rename the column Country.Code to Country_Code
fert_countryInfo <- rename(fert_countryInfo, c('Country_Code' = 'Country.Code'))
## left join fertDF (Fertility Rate Table) and fert_countryInfo (Fertility Country Info)
new_fertDF <- fertDF %>% left_join(fert_countryInfo)
## remove records without a region, they are the region aggregation from World Bank
new_fertDF <- new_fertDF[new_fertDF$Region != "",]
## remove columns: SpecialNotes, X, TableName
new_fertDF <- new_fertDF[, -which(names(new_fertDF) %in% c("SpecialNotes", "X", "TableName"))]
## deal with missing values: replace with mean of the country/region, 
## if no value detected, delete all records of this country/region
mean_fert <- aggregate(cbind(Mean_FertRate = FertilityRate) ~ Country_Code, data = new_fertDF, FUN = function(x){mean(x)})
### find out countries/regions without any fertility rate data and remove their records
no_fert <- setdiff((unique(new_fertDF$Country_Code)), mean_fert$Country_Code)
unique(new_fertDF[new_fertDF$Country_Code %in% no_fert,]$Country_Name)
new_fertDF <- new_fertDF[!(new_fertDF$Country_Code %in% no_fert),]
### replacing the ones with partial missing values with their mean fertility rate
new_fertDF <- new_fertDF %>% 
  group_by(Country_Code) %>% 
  mutate(FertilityRate= ifelse(is.na(FertilityRate), 
                               mean(FertilityRate, na.rm =TRUE), FertilityRate))
## check if it still exists NA values in Fertility Rate
any(is.na(new_fertDF$FertilityRate))
## check any other missing values in other columns of this data set
any(is.na(new_fertDF))
unique(new_fertDF[new_fertDF$IncomeGroup == '',]$Country_Name)
## manually replacing Venezuela's income group based on online info
new_fertDF[new_fertDF$Country_Code == 'VEN',]$IncomeGroup <- 'Unclassified'
## export clean data set
write.csv(new_fertDF, "anly-501-project-yeyaxin1103/data/01-modified-data/FertilityRate_Clean.csv", row.names = FALSE)
