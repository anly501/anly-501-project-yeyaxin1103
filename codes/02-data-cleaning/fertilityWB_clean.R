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

fert_countryInfo <- read.csv('./../data/00-raw-data/Downloaded_Data/FertilityRate_WB/Fertility_CountryInfo_Raw.csv', header = TRUE)
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
#write.csv(new_fertDF, "anly-501-project-yeyaxin1103/data/01-modified-data/FertilityRate_Clean.csv", row.names = FALSE)


# -------- GDP per Capita World Bank ----------------- #
gdpDF <- read.csv('../../data/00-raw-data/Downloaded_Data/WB_GDPperCapita/gdp.csv', header = FALSE)
## remove first few extra rows
gdpDF <- gdpDF[-c(1,2),]
## make first row column names and remove first row
colnames(gdpDF) <- gdpDF[1,]
gdpDF <- gdpDF[-c(1),]
## remove white space from column names
names(gdpDF) <- gsub(" ", "_", names(gdpDF))
## remove columns: Indicator_Name, Indicator_Code, 2021, NA
gdpDF <- gdpDF[, -which(names(gdpDF) %in% c("Indicator_Name", "Indicator_Code", "2021", "NA", "Country_Name"))]
## melting (1960 - 2020)
gdpDF <- gdpDF %>% pivot_longer(cols = -c(Country_Code), 
                                  names_to = 'year', values_to = 'GDPperCapita_USD')
## deal with missing values: replace with mean of the country/region, 
## if no value detected, delete all records of this country/region
mean_gdp <- aggregate(cbind(Mean_GDPperCapita = GDPperCapita_USD) ~ Country_Code, data = gdpDF, FUN = function(x){mean(x)})
### find out countries/regions without any fertility rate data and remove their records
no_gdp <- setdiff((unique(gdpDF$Country_Code)), mean_gdp$Country_Code)
unique(gdpDF[gdpDF$Country_Code %in% no_gdp,]$Country_Name)
gdpDF <- gdpDF[!(gdpDF$Country_Code %in% no_gdp),]
### replacing the ones with partial missing values with their mean fertility rate
gdpDF <- gdpDF %>% 
  group_by(Country_Code) %>% 
  mutate(GDPperCapita_USD = ifelse(is.na(GDPperCapita_USD), 
                               mean(GDPperCapita_USD, na.rm =TRUE), GDPperCapita_USD))
## check any other missing values in other columns of this data set
any(is.na(gdpDF))
# change the type of column year to numeric
gdpDF$year <- as.numeric(gdpDF$year)
# merge with new_fertDF
new_fertDF <- new_fertDF %>% inner_join(gdpDF)


# -------- Human Development Index World Bank ----------------- #
hdiDF <- read.csv('../../data/00-raw-data/Downloaded_Data/Human_Dev_Index/hdi.csv', header = TRUE)
# drop country name column ("Entity")
hdiDF <- hdiDF[, -which(names(hdiDF) %in% c("Entity"))]
# Change column names
colnames(hdiDF) <- c("Country_Code", "year", "Human_Dev_Index")
# merge with new_fertDF
new_fertDF <- new_fertDF %>% left_join(hdiDF)
## deal with missing values: replace with mean of the country/region, 
## if no value detected, delete all records of this country/region
mean_hdi <- aggregate(cbind(Mean_HDI = Human_Dev_Index) ~ Country_Code, data = new_fertDF, FUN = function(x){mean(x)})
### find out countries/regions without any fertility rate data and remove their records
no_hdi <- setdiff((unique(new_fertDF$Country_Code)), mean_hdi$Country_Code)
new_fertDF <- new_fertDF[!(new_fertDF$Country_Code %in% no_hdi),]
### replacing the ones with partial missing values with their mean fertility rate (2018-2020)
new_fertDF <- new_fertDF %>% 
  group_by(Country_Code) %>% 
  mutate(Human_Dev_Index = ifelse(is.na(Human_Dev_Index), 
                                   mean(Human_Dev_Index, na.rm =TRUE), Human_Dev_Index))
## check any other missing values in other columns of this data set
any(is.na(new_fertDF))

# -------- Human Development Index World Bank ----------------- #
eduDF <- read.csv('../../data/00-raw-data/Downloaded_Data/WB_tertiarySchoolEnroll/higherEdu.csv', header = FALSE)
## remove first few extra rows
eduDF <- eduDF[-c(1,2),]
## make first row column names and remove first row
colnames(eduDF) <- eduDF[1,]
eduDF <- eduDF[-c(1),]
## remove white space from column names
names(eduDF) <- gsub(" ", "_", names(eduDF))
## remove columns: Indicator_Name, Indicator_Code, 2021, NA
eduDF <- eduDF[, -which(names(eduDF) %in% c("Indicator_Name", "Indicator_Code", "2021", "NA", "Country_Name"))]
## melting (1960 - 2020)
eduDF <- eduDF %>% pivot_longer(cols = -c(Country_Code), 
                                names_to = 'year', values_to = 'Tertiary_school_Enroll_Pctg')
## deal with missing values: replace with mean of the country/region, 
## if no value detected, delete all records of this country/region
mean_edu <- aggregate(cbind(Mean_higherEdu = Tertiary_school_Enroll_Pctg) ~ Country_Code, data = eduDF, FUN = function(x){mean(x)})
### find out countries/regions without any fertility rate data and remove their records
no_edu <- setdiff((unique(eduDF$Country_Code)), mean_edu$Country_Code)
#unique(gdpDF[gdpDF$Country_Code %in% no_gdp,]$Country_Name)
eduDF <- eduDF[!(eduDF$Country_Code %in% no_edu),]
### replacing the ones with partial missing values with their mean fertility rate
eduDF <- eduDF %>% 
  group_by(Country_Code) %>% 
  mutate(Tertiary_school_Enroll_Pctg = ifelse(is.na(Tertiary_school_Enroll_Pctg), 
                                   mean(Tertiary_school_Enroll_Pctg, na.rm =TRUE), Tertiary_school_Enroll_Pctg))
## check any other missing values in other columns of this data set
any(is.na(eduDF))
# change the type of column year to numeric
eduDF$year <- as.numeric(eduDF$year)
# merge with new_fertDF
new_fertDF <- new_fertDF %>% inner_join(eduDF)


# remove country records before the year 1990
new_fertDF <- new_fertDF[!(new_fertDF$year < 1990),]

# label the data based on fertility rate (Below Replacement, Above Replacement)
new_fertDF <- new_fertDF %>% mutate(label = ifelse((FertilityRate >= 2.1), "Above Replacement", "Below Replacement"))

## export clean data set
write.csv(new_fertDF, "../../data/01-modified-data/FertilityRate_Clean.csv", row.names = FALSE)