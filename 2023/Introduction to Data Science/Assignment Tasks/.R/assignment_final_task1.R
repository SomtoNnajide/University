---
title: "Final Assignment, Task 1"
author: "Somtochukwu Nnajide"
date: "2023-04-26"
output:
  pdf_document: default
  html_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
*** 

# Task 1: Data Preparation and Wrangling: 	(30 marks)

1.	import the data from the CSV files and store them into dataframes named appropriately. 

```{r, eval=FALSE}
# The code and code description of this component go below here
library(tidyverse)
library(lubridate)

#manually read csv files as tibbles
countries_data = read_csv("data/data/Countries.csv")
covid19_data = read_csv("data/data/Covid19.csv")
recovered_data = read_csv("data/data/Recovered.csv")
test_data = read_csv("data/data/Tests.csv")

```


2.	Tidy up the dataframe driven from the “Recovered.csv” files to be compatible with the dataframe driven from the “Covid19.csv” file, _i.e._, every observation should have a record of recovered patients in one country in a single day. 


```{r, eval=FALSE}
# The code and code description of this component go below here

#convert from wide format to long format using gather()
recovered_data <- gather(recovered_data,
                         key = "Date",
                         value = "Recovered",
                         c(`2020.01.22` : `2020.05.05`))

recovered_data
```
3.	Change the column names in the dataframes were loaded from the following files accordingly.

```{r, eval=FALSE}
# The code and code description of this component go below here

#change column names using colnames(df)

colnames(covid19_data) <- c("Code", "Country", "Continent", "Date", "NewCases", "NewDeaths")
colnames(test_data) <- c("Code", "Date", "NewTests")
colnames(countries_data) <- c("Code", "Country", "Population", "GDP", "GDPCapita")
colnames(recovered_data) <- c("Country", "Date", "Recovered")

covid19_data
test_data
countries_data
recovered_data
```

4.	Ensure that all dates variables are of the same date format across all dataframes. 

```{r, eval=FALSE}
# The code and code description of this component go below here

#the format in covid19_data and test_data are %Y-%m-%d 
#change format in recovered_data to %Y-%m-%d using lubridate 
recovered_data$Date <- as.Date(format(ymd(recovered_data$Date), "%Y-%m-%d"))

#check Date columns again to ensure they are the same format
covid19_data["Date"]
test_data["Date"]
recovered_data["Date"]

```

5.	Considering the master dataframe is the one loaded from the “Covid19.csv” file, add new 5 variables to it from the other files (Recovered.csv, Tests.csv, Countries.csv). The 5 new added variables should be named (“Recovered”, “NewTests”, “Population”, “GDP”, “GDPCapita”) accordingly.

    [Hint: you may use the `merge` function to facilitate the alignment of the data of the different dataframes. You may use this format: `merge(x=df1,y=df2, [specify the merging dimension if needed])`, where df1 and df2 are the dataframes to be merged]

```{r, eval=FALSE}
# The code and code description of this component go below here

#merge dataframes
covid19_data <- merge(covid19_data, recovered_data, all.x = TRUE)
covid19_data <- merge(covid19_data, test_data, all.x = TRUE)
covid19_data <- merge(covid19_data, countries_data, all.x = TRUE)

#reorder columns
col_order = c("Code", "Country", "Continent", "Date", "NewCases", "NewDeaths", "Recovered", "NewTests", "Population", "GDP", "GDPCapita")
covid19_data <- covid19_data[, col_order]

covid19_data
```

6.	Check NAs in the merged dataframe and change them to `Zero`. 

```{r, eval=FALSE}
# The code and code description of this component go below here

#change NAs to numeric zero
for(col in colnames(covid19_data)){            
  for(val in covid19_data[[col]]){             
    if(is.na(val)){                                 
        covid19_data[[col]][match(val,covid19_data[[col]])] <- 0
    }
  }
}

covid19_data
```

7.	Using existing “Date” variable; add month and week variables to the master dataframe. 
    
    [Hint: you may use functions from `lubridate` package]

```{r, eval=FALSE}
# The code and code description of this component go below here

#add new columns using lubridate
covid19_data$Month <- month(covid19_data$Date, label = TRUE)
covid19_data$Week <- week(covid19_data$Date)

covid19_data <- covid19_data %>% arrange(Country)

covid19_data

```

8. Add four new variables to the master dataframe (“CumCases”, “CumDeaths”, “CumRecovered”, “CumTests”). These variables should reflect the cumulative relevant data up to the date of the observation; _i.e._, CumCases for country “X” at Date “Y” should reflect the total number of cases in country “X” since the beginning of recording data till the date “Y”. 

    [Hint: first arrange by date and country, then for each new variable to be added you need to group by country and mutate the new column using the cumsum function]

```{r, eval=FALSE}
# The code and code description of this component go below here

covid19_data <- covid19_data %>% 
  arrange(Date, Country) %>% 
  group_by(Country) %>% 
  mutate(CumCases = cumsum(NewCases),
         CumDeaths = cumsum(NewDeaths),
         CumRecovered = cumsum(Recovered),
         CumTests = cumsum(NewTests))

covid19_data
```

9. Add two new variables to the master dataframe (“Active”, “FatalityRate”). Active variable should reflect the infected cases that has not been closed yet (by either recovery or death), and it could be calculated from (CumCases – (CumDeaths + CumRecovered)). On the other hand, FatalityRate variable should reflect the percentages of death to the infected cases up to date and it could be calculated from (CumDeaths / CumCases). 

```{r, eval=FALSE}
# The code and code description of this component go below here

covid19_data <- covid19_data %>% 
  mutate(Active = CumCases - (CumDeaths + CumRecovered),
         FatalityRate = CumDeaths / CumCases)

#replace NaN values with 0
covid19_data$FatalityRate[is.nan(covid19_data$FatalityRate)] <- 0

covid19_data
```

10. Add four new variables to the master dataframe (“Cases_1M_Pop”, “Deaths_1M_Pop”, “Recovered_1M_Pop”, “Tests_1M_Pop”) These variables should reflect the cumulative relevant rate per one million of the corresponding country population, (i.e Cases_1M_Pop for country “X” at Date “Y” should reflect the total number of new cases up to date “Y” per million people of country “X” population)

    [Hint: Cases_1M_Pop = CumCases*(10^6) / Population)]

```{r, eval=FALSE}
# The code and code description of this component go below here

covid19_data <- covid19_data %>% 
  mutate(Cases_1M_Pop = CumCases*(10^6)/Population,
         Deaths_1M_Pop = CumDeaths*(10^6)/Population,
         Recovered_1M_Pop = CumRecovered*(10^6)/Population,
         Tests_1M_Pop = CumTests*(10^6)/Population)

covid19_data

```

**Task 1 final Report**: To ensure that this task has been finished correctly, run the following code and obtain the output as part of your knitted report. This will be used in marking this task.  

```{r, eval=FALSE}

problems(covid19_data) # in case if you are reading the data into tibbles

head(covid19_data)

cat("Number of columns is:", ncol(covid19_data), "and number of rows is:", nrow(covid19_data), "\n")

# check for specific values for the newly added columns, eg. deaths in a specific day
print(covid19_data$Recovered[10001])
print(covid19_data$NewTests[10001])
print(covid19_data$Population[10001])
print(covid19_data$GDP[10001])
print(covid19_data$GDPCapita[10001])
print(covid19_data$Cases_1M_Pop[6004])
print(covid19_data$Deaths_1M_Pop[6004])
print(covid19_data$Recovered_1M_Pop[6004])
print(covid19_data$Tests_1M_Pop[6004])

# check date format
is.na(as.Date(covid19_data$Date[200],  format = "%Y-%m-%d"))

# check week and month of a specific value
print(covid19_data$Week[3000])
print(covid19_data$Month[3000])

```

Please run this chunk as well

```{r, eval=FALSE}
#write master dataframe to csv file
#to be used in tasks 2, 3 and 4

write_csv(covid19_data, "masterFile.csv")

```


```{asis, echo=TRUE}
Final Report Output

----------------------------------
Number of columns is: 23 and number of rows is: 15029 
[1] 6482
[1] 9135
[1] 81800269
[1] 460976
[1] 5680
[1] 159.3805
[1] 1.571219
[1] 1.571219
[1] 1443.558
[1] FALSE
[1] 7
[1] Feb
Levels: Jan < Feb < Mar < Apr < May < Jun < Jul < Aug < Sep < Oct < Nov < Dec
----------------------------------

```

----

*** 
