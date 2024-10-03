#Loading tidyverse library packages
library(tidyverse)

#Imported data set - I imported the data set without using read.csv
#Making a copy of the dataset, called gp_hiv
gp_hiv <- indicator_hiv_estimated_prevalence_15_49

#Viewing the data set to understand it. Identifying how I improve this and make it useable.
view(gp_hiv)

#start to transform: order: Rename, gather, mutate format back into numbers, filter out empty cells, filter by years
gp_hiv2 <- gp_hiv%>%                                               #I duplicate the table to have another non-original version to work off.                                    
  rename(country = "Estimated HIV Prevalence% - (Ages 15-49)") %>% #Renaming column to country to be clearer
  gather(key = year, value = prevalence, -country) %>%             #Reformatting the table using gather()
  mutate(prevalence = as.numeric(prevalence)) %>%                  #gather() converted numbers to chr. So mutate() and as.numeric counter this
  mutate(year = as.numeric(year)) %>%
  filter(!is.na(country)) %>%                                      #Using filter(), is.na with !, to remove empty cells/rows/missing values
  filter(!is.na(prevalence)) %>%                                   
  filter(year > 1990)                                              #Using filter() to start table from 1991 

head(gp_hiv2)                                                      #Using head() and view() to check table
view(gp_hiv2)
                                                                   #Table looks good

# Part two
## Copied and pasted from sheet
gp_hiv2 %>%
  group_by(country) %>%
  summarise(MeanPrevalence = mean(prevalence)) %>%
  mutate(MeanPrevalence=round(MeanPrevalence,1)) %>%
  head()




