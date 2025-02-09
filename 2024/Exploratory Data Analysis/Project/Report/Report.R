---
title: "u3224942 EDA Report\n An Extensive analysis into the Ames Housing Dataset"
author: "Somtochukwu Nnajide"
date: "2024-04-16"
output: 
  pdf_document: 
    toc: true
    toc_depth: 4
    fig_width: 8
    fig_height: 5 
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

***

```{r Environment control, eval=FALSE, echo=FALSE}

rm(list = ls())

```

```{r Library installation, eval=FALSE, echo=FALSE}

#please install packages if needed
install.packages("DataExplorer")
install.packages("devtools")
install.packages("janitor")
install.packages("outliers")
install.packages("corrplot")
install.packages("ggpubr")
install.packages("lubridate")
install.packages("lmtest")
install.packages("car")
install.packages("knitr")
install.packages("plyr")

devtools::install_github('cttobin/ggthemr')

```

```{r Library importation, eval=TRUE, message=FALSE, echo=FALSE}

library(tidyverse)
library(ggplot2)
library(corrplot)
library(naniar)
library(DataExplorer)
library(ggpubr)
library(lubridate)
library(ggthemr)
library(caret)
library(randomForest)
library(car)
library(lmtest)
library(outliers)

```

```{r ggthemer, eval=TRUE, echo=FALSE}

ggthemr('earth', layout = "clear", type = "outer", spacing = 2)

```

```{r Datasets code, eval=TRUE, echo=FALSE, message=FALSE}

# Copies of the train and test data were created to keep the raw data untouched.

#Original datasets
train <- read_csv("train.csv")
test <- read_csv("test.csv")

#Copies of original datasets
train_data <- train
test_data <- test

```

# 1. Abstract

```{asis}

Rigorous pre-processing has been performed while maintaining dataset consistency across the train and test sets. Transitioning to an extensive exploratory data analysis where problems of interest are explored and insights are derived. Further pre-processing is performed with the help of random forests to feature engineer new variables and select significant features.

Finally an iterative and thorough modelling process is done with modelling algorithms; k-nearest neighbour, random forest and linear regression across different transformations to the target variable with the aim of selecting the best model with the lowest RMSE to predict sale price.

For the purposes of keeping this report readable, no code blocks will be shown in the pdf document. Please refer to the markdown file for code analysis if necessary.

```

# 2. Problem Identification

```{asis}

The Ames Housing Dataset is a renowned resource in machine learning and statistics, containing information on residential properties in Ames, Iowa, USA, along with their sale prices. With 2930 observations and 82 variables, it offers a comprehensive view of housing market dynamics (Kaggle, 2024). Key attributes include sale price, lot area, overall quality and neighborhood and these variables cover various factors influencing housing prices, such as size, age, quality, location, and amenities.

The dataset is often used to build predictive models on sale price and for advanced research in data science and machine learning.

Variables of Interest I will focus on are overall quality, neighbourhood and month sold, along with other feature engineered results in the report. Some of the questions I will attempt to address are:

* Which neighbourhoods are more expensive than the rest ?
* Which neighbourhoods have a higher build quality than the rest ?
* What was the trend of median and mean price over the years ? 
* What was the trend of number of sales across the years ?
* Was there a seasonal effect on the number of sales ?
* Does home quality affect its sale price ?
* What is the relatioship between a large square feet and sale price ?
* Are houses with more bathrooms more expensive ?

etc.., amongst many othe questions and problem areas I will be addressing in this report.
```

# 3. Data Pre-processing

```{asis Summary of data pre-processing}

Data preprocessing is a crucial step in the data analysis pipeline that involves transforming raw data into a clean and structured format suitable for analysis (Mesevage, 2021). It encompasses a variety of techniques and procedures aimed at preparing the data for further analysis and modelling (Mesevage, 2021). The importance of data pre-processing is highlighted below:

* Quality Assurance: Raw data often contain errors, inconsistencies, missing values, or outliers. Data cleaning helps identify and rectify such issues, ensuring data quality and reliability.

* Accuracy: Clean data leads to more accurate analysis and modeling outcomes. By removing errors and inconsistencies, preprocessing ensures that the insights derived from the data are trustworthy and reflect the true characteristics of the underlying data.

* Better Insights: Data preprocessing encourages the extraction of meaningful patterns, trends, and insights from the data. By removing noise and irrelevant information, preprocessing enhances the signal-to-noise ratio, making it easier to identify relevant patterns and relationships.

* Improved Model Performance: Clean and well-preprocessed data are essential for building accurate and robust predictive models. Models trained on dirty or unprocessed data are likely to produce unreliable predictions and perform poorly in real-world applications.

In my approach, I made sure to reflect all pre-processing performed on the train set unto the test set. This ensures consistency between both datasets and avoids modelling mismatches. Due to size of the dataset, I decided to clean every variable by a variety of methods depending on what is appropriate, methods are inclusive of replacing NA values, imputing medians, imputing modes, re-factoring orders etc.

```

```{r Datasets overview code, eval=FALSE, echo=FALSE}

# Brief overview of datasets to understand the structure and variable types

dim(train_data)
dim(test_data)

head(train_data)
head(test_data)

glimpse(train_data)
glimpse(test_data)

str(train_data)
str(test_data)

```

## Missing values identification and handling

```{asis Intro to NAs}

Columns with missing values were identified in each dataset. The table below shows an overview of the columns and the amount of NAs in descending order.

```

```{r NA handling code, eval=TRUE, echo=FALSE}

NA_train <- which(colSums(is.na(train_data)) > 0)
NA_test <- which(colSums(is.na(test_data)) > 0)

cat("Columns with missing values in train set\n") 
sort(colSums(sapply(train_data[NA_train], is.na)), decreasing = TRUE)

cat("\nColumns with missing values in test set\n")
sort(colSums(sapply(test_data[NA_test], is.na)), decreasing = TRUE)

```

```{asis NA observations}

The tables above indicate there are differences in the total number of missing values in both datasets. We also observe more than 50% of values in "PoolQC", "MiscFeature", "Alley" and "Fence" are marked as "NA". Further investigation will be done to determine if these are actually missing values or are labels marked as "NA" for the variable. 

```

```{asis NA plots description}
The plots below are a visual representation of the missing values.
```

```{r NA plots code, eval=TRUE, echo=FALSE}

gg_miss_var(train_data) + theme(axis.text.y = element_text(size = 5))
gg_miss_var(test_data) + theme(axis.text.y = element_text(size = 5))

```

```{asis NA columns explanation}
We also notice there are more columns with missing values in the test set than training set, most probably has to do with how the data was split.
```

```{r NA columsn description, eval=TRUE, echo=FALSE}

cat('There are', length(NA_train), 'columns with missing values in the train set\n')
cat('There are', length(NA_test), 'columns with missing values in the test set')

```

```{asis plot-missing}
Determine the proportion of missing values in both dataframes.
```

```{r plot-missing code, eval=TRUE, echo=FALSE}

plot_missing(train_data, missing_only = T, 
             title = "Proportion of missing values in Train set")
plot_missing(test_data, missing_only = T, 
             title = "Proportion of missing values in Test set")

```

## Distribution of target variable

```{asis Saleprice distribution}

Knowing the proportions of the missing values, let's go further a bit and explore the distribution of the SalePrice in train_data using ggplot to understand its skewness and identify potential outliers.

```

### Histogram
```{r Saleprice hist code, eval=TRUE, echo=FALSE, warning=FALSE}

ggplot(train_data, aes(x = SalePrice, fill = ..count..)) + 
  geom_histogram(bins = 30) +
  scale_fill_gradient(name = "Number of observations",
                      low = "blue",
                      high = "red") +
  labs(title = "Distribution of Sale Prices", x = "Sale Price", y = "Frequency") +
  scale_x_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  geom_vline(aes(xintercept = median(train_data$SalePrice), color = "Median"), 
             linetype="dashed", size=1, show.legend = TRUE) +
  geom_vline(aes(xintercept = mean(train_data$SalePrice), color = "Mean"), 
             linetype="dashed", size=1, show.legend = TRUE) +
  scale_color_manual(name = "Summary statistics",
                     values = c("Median" = "turquoise", "Mean" = "green"),
                     labels = c("Mean Saleprice", "Median Saleprice")) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5))

```

```{asis Saleprice hist description}

A right skewed histogram makes sense in this context as more expensive sales are generally expected to be less frequent. Good to note the mean and median saleprices are in the range of $150k to $200k, which may indicate homes in Ames are on average affordable.

Some extreme outliers observed with sales price above $600,000. Further investigation will be done to determine which variables strongly influence a high sale price. This might also broadly indicate homes in commercial aread or homes built on high land value.

```

### Boxplot

```{r Saleprice boxplot code, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x="", y=SalePrice)) +
  geom_boxplot(col = "white", outlier.color = "green", 
               outlier.shape = 20, outlier.size = 2) +
  stat_summary(fun="mean",
               geom="point",
               color="blue",
               fill="blue",
               size=3,
               shape=20) +
  labs(title = "Boxplot of Sale Price", x = " ", y = "Sale price") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      axis.title.x = element_text(size = 12, hjust = 0.5),
      axis.title.y = element_text(size = 12, hjust = 0.5)) 

```

```{asis Saleprice boxplot description}

Boxplot plotted to place emphasis on the histogram's skew. A better representation of outliers is also observed, noting that they are significantly more than what the histogram potrays. 

Further processing will be done to reduce the number of extreme outliers and bring the target variable closer to a normal distribution.

```

## Exploring Numeric and Categorical variables

```{asis Section intro}

In this sub-section, we explore the numeric and categorical variables so we can identify the distributions and frequencies of the variables in train_data. This will also help us develop further insight into the "NA" values we identified earlier.

Please note, the plots are too many to be shown in this report so please refer to the code in the markdown file.

```

```{r Hist and Bars of variables, eval=FALSE, echo=FALSE}
# Numeric variable distributions
plot_histogram(train_data)
# Categorical variable analysis
plot_bar(train_data)
```

```{asis Explanation of plots, echo=TRUE}

From the plots, we identified that most NAs are not really missing values, but in most cases it means a "None". By example, we have a lot of NAs in "PoolQC" and Alley, but investigating the metadata further, we found out that you cannot have "PoolQC" if you do not have a pool and cannot have an "Alley" if there is no alley access. 

The same reasoning goes for some other features too. The final decision to handle these is not delete the variables but rather replace the "NA" values with "None" for better interpretation

Bar plots of "PoolQc" and "Alley" with "NA" values are shown below to demonstrate my reasoning.

```

### Barplots of PoolQC and Alley

```{r Barplot of Alley and PoolQC, eval=TRUE, echo=FALSE}

poolqc_bar <- ggplot(data = train_data, aes(x = PoolQC)) +
  geom_bar(fill = "tomato2") +
  coord_flip() +
  labs(title = "Barplot of PoolQC", x = "Pool Quality", y = " ") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 12, hjust = 0.5)) 

alley_bar <- ggplot(data = train_data, aes(x = Alley)) +
  geom_bar(fill = "tomato2") +
  coord_flip() +
  labs(title = "Barplot of Alley", x = "Type of Alley", y = "Count") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 12, hjust = 0.5),
    axis.title.y = element_text(size = 12, hjust = 0.5)) 

ggarrange(poolqc_bar, alley_bar, nrow = 2, ncol = 1)

```


```{asis Description of Pool and Alley barplots}

From the metadata, we understand that "NA" in PoolQC means "No Pool" and "NA" in Alley means "No alley access". Therefore these are not missing values in the sense that they do not exist in the dataset.

Also interesting to note is that a number of homes do not own pools. Could it be because pool maintenance is expensive in Ames? Recall how the mean and median sale price of homes were in the $150k - $200k range, perhaps pools are not common in homes with these price tags in America? On the assumption that these price tags represent the lower middle class.

```

### Replacing NA values with "None"

```{asis}
NA values in categorical vaues where appropriate replaced with "None". Please refer to markdown file to view code.
```

```{r Replace NAs with None, eval=TRUE, echo=FALSE}

#NA values are replaced with "None" where appropriate

################## Train Set #######################
train_data <- train_data %>% 
  mutate(
    across(c(PoolQC,MiscFeature,Alley,Fence,FireplaceQu,GarageType,
             GarageFinish,GarageQual,GarageCond,BsmtExposure,
             BsmtFinType1,BsmtFinType2,BsmtQual,BsmtCond,MasVnrType), 
           ~ replace_na(.,"None"))
  )

################## Test Set #######################
test_data <- test_data %>% 
  mutate(
    across(c(PoolQC,MiscFeature,Alley,Fence,FireplaceQu,GarageType,
             GarageFinish,GarageQual,GarageCond,BsmtExposure,
             BsmtFinType1,BsmtFinType2,BsmtQual,BsmtCond,MasVnrType), 
           ~ replace_na(.,"None"))
  )

```

```{asis}
Proportion of missing values after replacement.
```

```{r, eval=TRUE, echo=FALSE}
plot_missing(train_data, missing_only = T, 
             title = "Proportion of missing valeus in Train data")
plot_missing(test_data, missing_only = T, 
             title = "Proportion of missing values in Test data")
```

```{r, eval=TRUE, echo=FALSE}

NA_train <- which(colSums(is.na(train_data)) > 0)
NA_test <- which(colSums(is.na(test_data)) > 0)

cat("Columns with missing values in train set after NA replacement\n") 
sort(colSums(sapply(train_data[NA_train], is.na)), decreasing = T)

cat("\nColumns with missing values in test set after NA replacement\n")
sort(colSums(sapply(test_data[NA_test], is.na)), decreasing = T)

```

```{asis}

Based on these findings, the number of missing values in "LotFrontage", "GarageYrBlt" and "MasVnrArea" across both sets are still quite high.

More investigation will be done to determine how to handle them by checking the structure and summary of the dataset.

```

```{r, eval=FALSE, echo=FALSE}
str(train_data)
summary(train_data)
```

## Data Formatting and Categorization

```{asis, echo=TRUE}

Further investigation into the structure and summary of train_data points out that multiple categorical values can be transformed into factors or ordered factors to ensure categorical data are correctly represented in the dataset. The variables fall into one this two categories:

Nominal Variables (No Order): Variables like MSZoning, Street, and Neighborhood represent categories without any inherent ordering. We will convert these into factors to ensure that modeling algorithms treat them as distinct categories rather than numbers with magnitudes.

Ordinal Variables (Order Matters): Variables like ExterQual, BsmtQual, and HeatingQC possess a meaningful order in their categories. We will convert these into ordered factors to preserve this order.

```

### Factors

```{asis}
Conversion of nominal variables. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

columns_to_factor <- c(
  "MSZoning", "MiscFeature", "Alley", "Street", "LandContour",
  "Utilities", "LotConfig", "Neighborhood", "BldgType", "RoofStyle",
  "RoofMatl", "Exterior1st", "Exterior2nd", "Foundation", "Heating",
  "CentralAir", "GarageType", "MoSold"
)

# Apply as.factor to specified columns
for (col_name in columns_to_factor){
  train_data[[col_name]] <- as.factor(train_data[[col_name]])
  
  test_data[[col_name]] <- as.factor(test_data[[col_name]])
}

```

### Ordered Factors

```{asis}
Conversion of ordinal variables. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

# Define a list of ordered levels for each variable
ordered_levels <- list(
  PoolQC = c("None", "Fa", "TA", "Gd", "Ex"),
  LotShape = c("Reg", "IR1", "IR2", "IR3"),
  LandSlope = c("Gtl", "Mod", "Sev"),
  HouseStyle = c("1Story", "1.5Unf", "1.5Fin", "2Story", "2.5Unf", "2.5Fin", "SFoyer",
                 "SLvl"),
  MasVnrType = c("None", "CBlock", "BrkCmn", "BrkFace", "Stone"),
  ExterQual = c("Po", "Fa", "TA", "Gd", "Ex"),
  ExterCond = c("Po", "Fa", "TA", "Gd", "Ex"),
  BsmtQual = c("None", "Po", "Fa", "TA", "Gd", "Ex"),
  BsmtCond = c("None", "Po", "Fa", "TA", "Gd", "Ex"),
  BsmtExposure = c("None", "No", "Mn", "Av", "Gd"),
  BsmtFinType1 = c("None", "Unf", "LwQ", "Rec", "BLQ", "ALQ", "GLQ"),
  BsmtFinType2 = c("None", "Unf", "LwQ", "Rec", "BLQ", "ALQ", "GLQ"),
  HeatingQC = c("Po", "Fa", "TA", "Gd", "Ex"),
  Electrical = c("FuseP", "FuseF", "FuseA", "SBrkr", "Mix"),
  KitchenQual = c("Po", "Fa", "TA", "Gd", "Ex"),
  Functional = c("Sal", "Sev", "Maj2", "Maj1", "Mod", "Min2", "Min1", "Typ"),
  FireplaceQu = c("None", "Po", "Fa", "TA", "Gd", "Ex"),
  GarageFinish = c("None", "Unf", "RFn", "Fin"),
  GarageQual = c("None", "Po", "Fa", "TA", "Gd", "Ex"),
  GarageCond = c("None", "Po", "Fa", "TA", "Gd", "Ex"),
  PavedDrive = c("N", "P", "Y")
)

# Apply ordered levels to test_data columns
for (col_name in names(ordered_levels)){
  train_data[[col_name]] <- ordered(train_data[[col_name]], 
                                   levels = ordered_levels[[col_name]])
  
  test_data[[col_name]] <- ordered(test_data[[col_name]], 
                                   levels = ordered_levels[[col_name]])
}

```

```{r, eval=FALSE, echo=FALSE}
#run this to check structure after factorisation
str(train_data)
```

### MSSubClass

```{asis}

This variable identifies the type of dwelling involved in the sale. The classes are encoded as numbers but are inherently categorical, as seen below:

* 20  1-STORY 1946 & NEWER ALL STYLES
* 30  1-STORY 1945 & OLDER
* 40  1-STORY W/FINISHED ATTIC ALL AGES
* 45  1-1/2 STORY - UNFINISHED ALL AGES
* 50  1-1/2 STORY FINISHED ALL AGES
* 60  2-STORY 1946 & NEWER
* 70  2-STORY 1945 & OLDER
* 75  2-1/2 STORY ALL AGES
* 80  SPLIT OR MULTI-LEVEL
* 85  SPLIT FOYER
* 90  DUPLEX - ALL STYLES AND AGES
* 120  1-STORY PUD (Planned Unit Development) - 1946 & NEWER
* 150  1-1/2 STORY PUD - ALL AGES (Not in the dataset we are working with)
* 160  2-STORY PUD - 1946 & NEWER
* 180  PUD - MULTILEVEL - INCL SPLIT LEV/FOYER
* 190  2 FAMILY CONVERSION - ALL STYLES AND AGES

Therefore, we will re-value the codes to their labels to improve readability. Please refer to markdown to view code.

```

```{r, eval=TRUE, echo=FALSE}

################## Train Set #######################
train_data$MSSubClass <- as.factor(train_data$MSSubClass)

#revalue for better readability
train_data$MSSubClass <- plyr::revalue(train_data$MSSubClass, 
                                 c('20'='1 story 1946+', 
                                   '30'='1 story 1945-', 
                                   '40'='1 story fin attic', 
                                   '45'='1.5 story unf',
                                   '50'='1.5 story fin', 
                                   '60'='2 story 1946+', 
                                   '70'='2 story 1945-', 
                                   '75'='2.5 story all ages',
                                   '80'='split/multi level', 
                                   '85'='split foyer',
                                   '90'='duplex all style/age', 
                                   '120'='1 story PUD 1946+',
                                   '160'='2 story PUD 1946+',
                                   '180'='PUD multilevel', 
                                   '190'='2 family conversion'))

################## Test Set #######################
test_data <- test_data[-which(test_data$MSSubClass==150),] #drop unused level

test_data$MSSubClass <- as.factor(test_data$MSSubClass)

#revalue for better readability
test_data$MSSubClass <- plyr::revalue(test_data$MSSubClass, 
                                 c('20'='1 story 1946+', 
                                   '30'='1 story 1945-', 
                                   '40'='1 story fin attic', 
                                   '45'='1.5 story unf',
                                   '50'='1.5 story fin', 
                                   '60'='2 story 1946+', 
                                   '70'='2 story 1945-', 
                                   '75'='2.5 story all ages',
                                   '80'='split/multi level', 
                                   '85'='split foyer',
                                   '90'='duplex all style/age', 
                                   '120'='1 story PUD 1946+',
                                   '160'='2 story PUD 1946+',
                                   '180'='PUD multilevel', 
                                   '190'='2 family conversion'))


```

### LotFrontage

```{asis}
Since "LotFrontage" might vary by neighborhood, a common strategy is to impute missing values based on the median LotFrontage of the neighborhood. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

################## Train Set #######################
train_data <- train_data %>%
  group_by(Neighborhood) %>%
  mutate(LotFrontage = ifelse(is.na(LotFrontage), 
                              median(LotFrontage, na.rm = TRUE), LotFrontage)) %>%
  ungroup()

################## Test Set #######################
test_data <- test_data %>%
  group_by(Neighborhood) %>%
  mutate(LotFrontage = ifelse(is.na(LotFrontage), 
                              median(LotFrontage, na.rm = TRUE), LotFrontage)) %>%
  ungroup()

```

### MasVnrArea

```{asis}
Since "MasVnrArea" is numeric and has a few missing values, these could be imputed by a central tendency measure. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

################## Train Set #######################
train_data$MasVnrArea[is.na(train_data$MasVnrArea) & train_data$MasVnrType == "None"] <- 0
train_data$MasVnrArea[is.na(train_data$MasVnrArea)] <- median(train_data$MasVnrArea, 
                                                              na.rm = TRUE)

################## Test Set #######################
test_data$MasVnrArea[is.na(test_data$MasVnrArea) & test_data$MasVnrType == "None"] <- 0
test_data$MasVnrArea[is.na(test_data$MasVnrArea)] <- median(test_data$MasVnrArea,
                                                            na.rm = TRUE)

```

### Electrical

```{asis}
Since there is only one missing value in Electrical, and this is a categorical variable, the simplest approach would be to impute this with the mode. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

################## Train Set #######################
mode_electrical <- names(which.max(table(train_data$Electrical)))
train_data$Electrical[is.na(train_data$Electrical)] <- mode_electrical

################## Test Set #######################
mode_electrical <- names(which.max(table(test_data$Electrical)))
test_data$Electrical[is.na(test_data$Electrical)] <- mode_electrical

```

###  Impute GarageYrBlt with YearBuilt

```{asis}

For homes where GarageYrBlt is missing, we'll use the year the house was built (YearBuilt). This assumes that the garage was constructed concurrently with the house, since the datasets were inspected and we notice that, frequently, the YearBuilt is similar to the GarageYrBlt.

Please refer to markdown to view code.

```

```{r, eval=FALSE, echo=FALSE}
#run this code to verify correspondence of YearBuilt with GarageYrBlt
train_data %>% select(YearBuilt, GarageYrBlt)
```

```{r, eval=TRUE, echo=FALSE}

train_data$GarageYrBlt[is.na(train_data$GarageYrBlt)] <- train_data$YearBuilt[is.na(train_data$GarageYrBlt)]

test_data$GarageYrBlt[is.na(test_data$GarageYrBlt)] <- test_data$YearBuilt[is.na(test_data$GarageYrBlt)]

```

### Verifying imputations

```{r, eval=TRUE, echo=FALSE}
plot_missing(train_data, 
             title = "Proportion of missing values in Train set")
plot_missing(test_data, missing_only = T, 
             title = "Proportion of missing values in Test set")
```

```{asis}

We observe there are still some missing values in the test set. Manual imputation will be used to handle them.

* MSZoning - Imputation with the mode of this categorical variable.
* Utilities - As this is typically 'AllPub', imputation with the mode.
* Exterior1st and Exterior2nd - Imputation with the mode of these categorical variables.
* BsmtFinSF1, BsmtFinSF2, BsmtUnfSF, TotalBsmtSF - Missing, likely no basement; set to 0.
* BsmtFullBath and BsmtHalfBath- Missing, likely no basement; set to 0.
* KitchenQual - Imputation with the mode as it’s a categorical variable.
* Functional - Imputation with 'Typ' as it’s the most common category indicating typical
functionality.
* GarageCars and GarageArea - Missing, likely no garage; set to 0.
* SaleType - Imputation with the mode.

Please refer to markdown to view code.

```

```{r, eval=TRUE, echo=FALSE}

# function to calculate mode
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# applying imputations
test_data <- test_data %>%
  mutate(
    across(c(MSZoning, Exterior1st, Exterior2nd, 
             KitchenQual, SaleType),
           ~ replace_na(., Mode(.))),
    across(c(BsmtFinSF1, BsmtFinSF2, BsmtUnfSF,
             TotalBsmtSF, BsmtFullBath, BsmtHalfBath,
             GarageCars, GarageArea), ~ replace_na(., 0)),
    Utilities = replace_na(Utilities, "AllPub"),
    Functional = replace_na(Functional, "Typ")
  )


```


```{r, eval=TRUE, echo=FALSE}
cat("Number of NAs left in train set:", sum(is.na(train_data)), "\n")
cat("Number of NAs left in test set:", sum(is.na(test_data)))
```

```{r, eval=TRUE, echo=FALSE}
plot_missing(train_data, 
             title = "Proportion of missing values in Train set")
plot_missing(test_data, 
             title = "Proportion of missing values in Test set")
```

```{asis}
Up to this point, all NA values have been handled, variables have been factorised, categorised and re-encoded and the datasets are ready for exploratory analysis and modelling
```


# 4. Exploratory Data Analysis

```{asis}

In this section, I explore relationships between variables of interest and their relationship with SalePrice. Some questions explored include; 

* Neighbourhood - which neighbourhoods are more expensive than the rest ?, 
* Yrsold - what was the trend of median price over the years ? 
* MoSold - was there a seasonal effect on the number of sales ?
* Overall Quality - does home quality affect its sale price ?

Further exploration will be conducted after new variables have been feature engineered in the next section.

```

## Pre-Feature Engineering Correlations

```{r, eval=TRUE, echo=FALSE}

# select only numeric columns
numericCols <- train_data %>% select_if(is.numeric)

#correlations of numeric variables
cor_numCols <- cor(numericCols) 

#sort on decreasing correlations with SalePrice
cor_sorted <- as.matrix(sort(cor_numCols[,'SalePrice'], decreasing = T))

#select only high correlations
corHigh <- names(which(apply(cor_sorted, 1, function(x) abs(x)>0.5)))
cor_numCols <- cor_numCols[corHigh, corHigh]

#plot correlation
corrplot.mixed(cor_numCols, tl.col="black", tl.pos = "lt", 
               tl.cex = 0.7, cl.cex = .7, number.cex=.7)

```

```{asis}
Correlations which were above 0.5 with SalePrice was plotted develop a bit of insight into some of the questions listed above. Overall Quality has the highest correlation with SalePrice hence we expect that more expensive homes should tend to have a higher quality. We will investigate this trend.

Please note, this correlation was done before feauture engineering therefore rankings of variables might change. Multicollinearity will also be handled later in this report.

```

## Scatterplot between SalePrice and Ground Living Area

```{r, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x = GrLivArea, y = SalePrice)) +
  geom_point(col = "#BC4F5A") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Scatteplot of Sales Price vs Ground Living Area",
       x = "Ground Living Area (square feet)") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))

```

```{asis}
Positive strong correlation between SalePrice and Ground Living Area. Indicating that bigger homes tend to have a higher fee. Some outliers spotted where large homes have relatively low prices. This might be due to the age of the house, or other factors at play.
```

## Scatterplot between SalePrice and Total Basement Area

```{r,eval=TRUE,echo=FALSE}

ggplot(train_data, aes(x = TotalBsmtSF, y = SalePrice)) +
  geom_point(col = "#EAB007") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Scatteplot of Sales Price vs Total Basement Area",
       x = "Total Basement Area (square feet)") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))

```

```{asis}
Positive strong correlation between SalePrice and Total Basement Area. Indicating that homes with large basements tend to have a higher fee. Some outliers spotted where large basements have relatively low prices. Again, this might be due to the age of the house, basement quality or other factors at play.
```

## Time Series of Median Sales Price

```{r, eval=TRUE, echo=FALSE}

m <- train_data %>% 
  group_by(YearBuilt) %>% 
  summarise(mp = median(SalePrice)) 

ggplot(m, aes(x = as.factor(YearBuilt))) +
  geom_line(aes(y = mp), group = 1, col = "#EE41E2") +
  scale_x_discrete(breaks = seq(1872, 2010, by = 23),
                     labels = seq(1872, 2010, by = 23)) +
  scale_y_continuous(name = "Median Sale Price (USD)", labels = scales::comma) +
  labs(title = "Time Series of Median SalePrice",
       x = "Year Built") + 
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
Time series shows trend of median prices gradually increasing over the years. Interesting spikes to note are the sharp increase in price shortly after 1872, a time period where there was an economic surge in North America and the 2007 recession. 

However, this is immediately followed by a sharp downturn, representing The Panic of 1873 (Library of Congress, 2024). This period lasted between 1873 up until 1878. This economic downturn later became known as the Long Depression after the stock market crash of 1929.

Also note the effect of The '07 Recession, before the spike up shortly before 2010.

```

## Time series of number of sales for each year

```{r, eval=TRUE, echo=FALSE, message=FALSE}

SalesPerYr <- train_data %>% 
  group_by(YrSold, MoSold) %>% 
  summarise(Count = n())

ggplot(SalesPerYr, aes(x = MoSold, y = Count, 
                       col = as.factor(YrSold), 
                       group = as.factor(YrSold))) +
  geom_line() +
  labs(title = "Time series of Number of sales for each month per year",
       y = "Number of Sales",
       x = "Month",
       color = "Year") +
  scale_x_discrete(labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 8),
        legend.position = "bottom") +
  scale_colour_brewer(palette = "Set2")

```

```{asis}

We see a trend where sales tend to increase across all years between the months of February to July, spanning across end of winter to the middle of summer. Sales begin to decline after August, most probably due to school terms resuming and a transition into the holiday period.

Seasonality is definitely at play here. Home buyers are less aggressive during the holiday months of November to January and the peak home buying season seems to occur during June, July and August.

Also note, trend line for 2010 ends in July, indicating the dataset does not have observations for months after July in 2010. These observations could be in the test data or they were simply not recorded.

```

## Trend of median sale price of each year

```{r, eval=TRUE, echo=FALSE}

medianSalePrice <- train_data %>% 
  group_by(YrSold) %>% 
  summarise(medianPrice = round(median(SalePrice)))

ggplot(medianSalePrice, aes(x = as.factor(YrSold))) +
  geom_point(aes(y = medianPrice), col = "turquoise") +
  geom_line(aes(y = medianPrice), col = "turquoise", group = 1) +
  labs(title = "Median Sale Price per year (USD)",
     y = "Median Sale Price (USD)",
     x = "Year") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        legend.position = "bottom",
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
Trend shows a sharp decrease in median sale price after 2007, highlighting the strong effect of the 2007 recession. An economic downturn caused by the burst of the US housing market and the global financial crisis (Investopedia, 2023). 
```

## Trend of mean sale price of each year

```{r, eval=TRUE, echo=FALSE}

meanSalePrice <- train_data %>% 
  group_by(YrSold) %>% 
  summarise(meanPrice = round(mean(SalePrice)))

ggplot(meanSalePrice, aes(x = as.factor(YrSold))) +
  geom_point(aes(y = meanPrice), col = "red") +
  geom_line(aes(y = meanPrice), col = "red", group = 1) +
  labs(title = "Mean Sale Price per year (USD)",
     y = "Mean Sale Price (USD)",
     x = "Year") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        legend.position = "bottom",
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
Similar decreasing trend in the average sale price after 2007.
```

## Combined trends for a holistic view

```{r, eval=TRUE, echo=FALSE}

combinedStats <- train_data %>% 
  group_by(YrSold) %>% 
  summarise(meanPrice = round(mean(SalePrice)),
            medianPrice = round(median(SalePrice)))

ggplot(combinedStats, aes(x = as.factor(YrSold))) +
  geom_point(aes(y = meanPrice, col = "Mean")) +
  geom_line(aes(y = meanPrice, col = "Mean"), group = 1) +
  geom_point(aes(y = medianPrice, col = "Median")) +
  geom_line(aes(y = medianPrice, col = "Median"), group = 1) +
  labs(title = "Trend of Mean and Median price over time",
       y = "Sale Price (USD)",
       x = "Year") +
  scale_color_manual("Legend", values = c("Mean"="red",
                                          "Median"="turquoise")) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        legend.position = "bottom",
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
Average sale price generally higher than the median sale price. This was also highlighted in the histogram plot earlier in this report.
```

## Frequency of Overall Quality

```{r, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x = OverallQual)) +
  geom_bar(fill = "#774C5C") +
  labs(title = "Frequency of Overall Quality",
       x = "Overall Quality",
       y = "Frequency") + 
  scale_x_continuous(breaks = seq(1, 10, by = 1), labels = seq(1, 10, by = 1)) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
We observe that more houses have an Overall Quality between 5 and 7, which might correlate to the median sale price being affordable. Fewer houses have a quality between 8 and 10 and we would expect these homes to have a higher median SalePrice than most.
```

## Distribution of SalesPrice across OverallQuality

```{r, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x = as.factor(OverallQual), y = SalePrice)) +
  geom_boxplot() +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Distribution of SalePrice across Overall Quality",
       x = "Overall Quality") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
Distribution confirms that homes with higher Overall Quality have a higher Sale Price, satisfying the expectations we established earlier.
```

## Average Overall Quality of neighbourhoods

```{r, eval=TRUE, echo=FALSE}

avgOverallQual <- train_data %>% 
  group_by(Neighborhood) %>% 
  summarise(meanQuality = mean(OverallQual)) 

avgOverallQual$Neighborhood <- reorder(avgOverallQual$Neighborhood,
                                       avgOverallQual$meanQuality,
                                       order = is.ordered(avgOverallQual),
                                       decreasing = T)

ggplot(avgOverallQual, aes(x = Neighborhood, y = meanQuality,
                                              fill = meanQuality)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(name = "Average Overall Quality",
                      low = "#d4a420", high = "#a83e05") +
  labs(title = "Average Overall Quality of Neighbourhoods",
       x = "Neighbourhood",
       y = "Overall Quality") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 0.5, size = 8),
        axis.text.y = element_text(size = 8.5),
        legend.position = "bottom",
        legend.title = element_text(vjust = 0.8)) +
  coord_flip() 

```

```{asis}
Distribution of average quality across neighbourhoods gives us an idea of which neighbourhoods we expect to have a higher median sale price than most. From this plot, the top three neighbourhoods are NridgHt, StoneBr, and NoRidge.
```

## Distribution of SalePrice across Neighbourhood

```{r, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x = reorder(Neighborhood,
                                                SalePrice,
                                                FUN = median), y = SalePrice)) +
  geom_boxplot(fill = "#9c24eb") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Distribution of SalePrice across Neighbourhood",
       x = "Neighbourhood") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 0.5, size = 8, angle = 45))

```

```{asis}
Distribution of sale price across neighbourhood supports our assumptions of neighbourhoods with high overall quality will have a higher median price than most. NridgHt, StoneBr, and NoRidge are again the top three neighbourhoods in this plot, a direct correlation with the plot above.
```

## Distribution of SalesPrice in wealthy neighbourhoods

```{asis}
A neighbourhood will be considered wealthy if the median saleprice is $100,000 above the median SalePrice, ie, greater than $263,000
```

```{r, eval=TRUE, echo=FALSE}

colors <- c("#d65df7", "#1ecfb5", "#fafa07")

highMedian <- train_data %>% 
  select(Neighborhood, SalePrice) %>% 
  group_by(Neighborhood) %>% 
  summarise(MedianPrice = median(SalePrice)) %>% 
  filter(MedianPrice >= 263000) %>% 
  arrange(desc(MedianPrice))

affluentNeigh <- train_data %>% filter(Neighborhood %in% highMedian$Neighborhood)

ggplot(affluentNeigh, aes(x = SalePrice, fill = Neighborhood, 
                                               color = Neighborhood)) +
  geom_density(alpha = 0.2) +
  scale_fill_manual(values = colors) +
  scale_color_manual(values = colors) +
  scale_x_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Density plot of Sale Price across wealthy Neighborohoods",
       y = "Density") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 0.5, size = 8),
        axis.text.y = element_text(size = 8.5))

```

```{asis}
Again, we see the neighbourhoods selected for this plot are NridgHt, StoneBr, and NoRidge. Most of their prices are in the range $200,000 to $400,000 with the NoRidge neighbourhood in particular being the suburb with extreme house prices. Maybe this is the newest neighbourhood in Ames? or the neighbourhood with the highest commercial/land value?
```

## Number of recorded sales per neighborhood

```{r, eval=TRUE, echo=FALSE}

neighobservations <- train_data %>% 
  group_by(Neighborhood) %>% 
  summarise(Count = n()) 

neighobservations$Neighborhood <- reorder(neighobservations$Neighborhood,
                                          neighobservations$Count,
                                          order = is.ordered(neighobservations),
                                          decreasing = T)

ggplot(neighobservations, aes(x = Neighborhood, y = Count)) +
  geom_bar(stat = "identity", fill = "#508222") +
  coord_flip() +
  labs(title = "Number of recorded sales per Neighbourhood",
       x = "Neighbourhood",
       y = "Number of Observations") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 0.5, size = 8),
        axis.text.y = element_text(size = 8.5))

```

```{r,eval=FALSE,echo=FALSE}
#calculate median sale price of NAmes
train_data %>% filter(Neighborhood == "NAmes") %>% summarise(mS = median(SalePrice))
```

```{asis}
Most sales were recorded in NAmes, a neighbourhood with a median sale price of $140,000. Expectedly, the neighbourhoods with the highest median sale prices; NridgHt, StoneBr, and NoRidge, recorded fewer sales.
```

```{asis}
From these EDAs, we expect Neighbourhood and Overall Quality to be significant variables in predicting SalePrice.
```

# 5. Further preprocessing

```{asis}
In this section, I perform further analysis into variables, aggregate variables into new ones which I believe will have a strong predictive relationship with SalePrice, handle multicollinearity where necessary, and select significant variables for predictive modelling based off correlation plots and variable importance plots from random forests.
```

## Feature Engineering

### Creating Total Bathrooms

```{asis}
The TotalBathrooms feature aggregates all bathroom data into a single feature by summing up the counts of full and half bathrooms in both the basement and above-grade (non-basement) areas of the house. Full baths count as one, while half baths count as 0.5, acknowledging that half baths have less utility than full baths.
```

```{r, eval=TRUE, echo=FALSE}

train_data$TotalBathrooms <- train_data$FullBath + (train_data$HalfBath*0.5) + train_data$BsmtFullBath + (train_data$BsmtHalfBath*0.5)

test_data$TotalBathrooms <- test_data$FullBath + (test_data$HalfBath*0.5) + test_data$BsmtFullBath + (test_data$BsmtHalfBath*0.5)

```

#### Boxplot of Total Bathrooms

## 
```{r, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x = as.factor(TotalBathrooms), y = SalePrice)) +
  geom_boxplot(fill = "#80AE4E") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Boxplot of Total Bathrooms",
       x = "Total Bathrooms") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))

```

```{asis}
The distribution follows the assumption that homes with more bathrooms will fetch a higher price. The solid dashed lines at Total Bathrooms 5 and 6 is due to the fact that there is only one observation for each of the levels, so their median sale price will simply be their sale price, as shown in the table below:
```

```{r, eval=TRUE, echo=FALSE}
# check  number of observations with more than 4.5 bathrooms
knitr::kable(train_data %>% 
               filter(TotalBathrooms > 4.5) %>% 
               select(Id, SalePrice, TotalBathrooms))
```

### Creating Total Square Feet

```{asis}

The TotalSquareFeet feature combines the living area above ground (GrLivArea) and the total basement area (TotalBsmtSF) to provide a better measure of the total usable area of the house. This aggregation might provide a more impactful predictor than considering these areas separately because combined space often translates more directly to consumer perceptions of size and value.

```

```{r, eval=TRUE, echo=FALSE}

train_data$TotalSquareFeet <- train_data$GrLivArea + train_data$TotalBsmtSF
test_data$TotalSquareFeet <- test_data$GrLivArea + test_data$TotalBsmtSF

```

#### Scatterplot of Sale Price vs Total Square Feet

## 

```{r, eval=TRUE, echo=FALSE}

ggplot(train_data, aes(x = TotalSquareFeet, y = SalePrice)) +
  geom_point(col = "#EF48C3") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  labs(title = "Scatteplot of Sales Price vs Total Square Feet",
       x = "Total Square Feet (square feet)") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))

```

```{asis}
Scatterplot shows a strong postive relationship between sale price and total square feet, indicating that larger homes are more expensive. Some outliers observeed where large homes have a low sale price.
```

### Creating House Age, Remodeled and IsNew

```{asis}

There are 3 variables that are relevant with regards to the Age of a house; YearBlt, YearRemodAdd, and YearSold. YearRemodAdd defaults to YearBuilt if there has been no Remodeling/Addition. I will use YearRemodeled and YearSold to determine the Age. However, as parts of old constructions will always remain and only parts of the house might have been renovated, I will also introduce a Remodeled Yes/No variable. This should be seen as some sort of penalty parameter that indicates that if the Age is based on a remodeling date, it is probably worth less than houses that were built from scratch in that same year.

```

```{r, eval=TRUE, echo=FALSE}

#0=No Remodeling, 1=Remodeling
train_data$Remod <- ifelse(train_data$YearBuilt == train_data$YearRemodAdd, 0, 1) 
test_data$Remod <- ifelse(test_data$YearBuilt == test_data$YearRemodAdd, 0, 1) 

# House Age
train_data$Age <- as.numeric(train_data$YrSold) - train_data$YearRemodAdd
test_data$Age <- as.numeric(test_data$YrSold) - test_data$YearRemodAdd

# isNew Variable
train_data$IsNew <- ifelse(train_data$YrSold == train_data$YearBuilt, 1, 0)
test_data$IsNew <- ifelse(test_data$YrSold == test_data$YearBuilt, 1, 0)

```

#### Relationship between Age and Saleprice

##

```{r, eval=TRUE, echo=FALSE}

medianAge <- train_data %>% 
  group_by(Age) %>% 
  summarise(medAge = median(SalePrice))

ggplot(medianAge, aes(x = as.factor(Age))) +
  geom_line(aes(y = medAge, group = 1), col = "#014E6D") +
  scale_x_discrete(name = "Age", breaks = seq(0,60, by=10),
                   labels = seq(0,60, by=10)) +
  labs(title = "Relationship between Saleprice and Age",
       y = "Median Sale Price (USD)") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))

```

```{asis}
Trend shows expected relationship where older homes will have a lower sale price.
```

#### Comparison between Remodelled and Unremodelled houses

##

```{r, eval=TRUE, echo=FALSE}

medianRemod <- train_data %>% 
  group_by(Remod) %>% 
  summarise(medRemod = median(SalePrice))

ggplot(medianRemod, aes(x = as.factor(Remod), y = medRemod)) +
  geom_bar(stat = "identity", fill = "#3E5954") +
  scale_x_discrete(labels = c("Not Remodelled", "Remodelled")) +
  labs(title = "Comparison between Remodelled and Unremodelled houses",
       x = "",
       y = "Median Sale Price (USD)") + 
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))
  
```

```{asis}
Remodelled homes have a lower median price than homes not remodelled.
```

#### Comparison between New and Old houses

##

```{r, eval=TRUE, echo=FALSE}

medianNew <- train_data %>% 
  group_by(IsNew) %>% 
  summarise(medNew = median(SalePrice))

ggplot(medianNew, aes(x = as.factor(IsNew), y = medNew)) +
  geom_bar(stat = "identity", fill = "#972025") +
  scale_x_discrete(labels = c("Old", "New")) +
  labs(title = "Comparison between New and Old houses",
       x = "",
       y = "Median Sale Price (USD)") + 
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        axis.text.x = element_text(vjust = 1, size = 9))
  
```

```{asis}
As expected, newer homes are more expensive than old homes.
```

## Post Feature Engineering Correlations

```{asis}
Correlation plot with new variables.
```

```{r, eval=TRUE, echo=FALSE}

# select only numeric columns
numericCols <- train_data %>% select_if(is.numeric)

#correlations of numeric variables
cor_numCols <- cor(numericCols) 

#sort on decreasing correlations with SalePrice
cor_sorted <- as.matrix(sort(cor_numCols[,'SalePrice'], decreasing = T))

#select only high correlations
corHigh <- names(which(apply(cor_sorted, 1, function(x) abs(x)>0.5)))
cor_numCols <- cor_numCols[corHigh, corHigh]

#plot correlation
corrplot.mixed(cor_numCols, tl.col="black", tl.pos = "lt", 
               tl.cex = 0.7, cl.cex = .7, number.cex=.7)

```

### Clean variable names

```{asis}
Ensuring variables are in proper format for random forests. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

train_data_clean <- janitor::clean_names(train_data, "upper_camel")
test_data_clean <- janitor::clean_names(test_data, "upper_camel")

```

### Random Forest with multicollinearity

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
baseRF1 <- randomForest(SalePrice ~.,
                       data = train_data_clean,
                       ntree = 100,
                       importance = T)

varImpPlot(baseRF1, sort = T, n.var = 20, 
           type = 1, main = "Variable Importance Plot with Multicollinearity",
           cex = .8, par(bg = "#2b2420"), color = "white",
           lcolor = "white", pt.cex = 1, col.main = "white", 
           col.lab = "white")

```

### Handling multicoliinearity

```{asis}
Variables with strong correlations with each other were cross-checked and the variable with a lower correlation to sale price was dropped. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

dropVars <- c("GrLivArea", "GarageArea", "TotalBsmtSf",
              "X1StFlrSf", "X2NdFlrSf", "TotRmsAbvGrd", 
              "GarageYrBlt", "FullBath")

train_data_clean <- train_data_clean[, !(names(train_data_clean) %in% dropVars)]
test_data_clean <- test_data_clean[, !(names(test_data_clean) %in% dropVars)]

```

### Correlations after multicollinearity variables removed

```{r, eval=TRUE, echo=FALSE}

# select only numeric columns
numericCols <- train_data_clean %>% select_if(is.numeric)

#correlations of numeric variables
cor_numCols <- cor(numericCols) 

#sort on decreasing correlations with SalePrice
cor_sorted <- as.matrix(sort(cor_numCols[,'SalePrice'], decreasing = T))

#select only high correlations
corHigh <- names(which(apply(cor_sorted, 1, function(x) abs(x)>0.5)))
cor_numCols <- cor_numCols[corHigh, corHigh]

#plot correlation
corrplot.mixed(cor_numCols, tl.col="black", tl.pos = "lt", 
               tl.cex = 0.7, cl.cex = .7, number.cex=.7)

```

```{asis}
Multicollinearity significantly reduced.
```

### Random Forest without multicollineariy

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
baseRF2 <- randomForest(SalePrice ~.,
                       data = train_data_clean,
                       ntree = 100,
                       importance = T)

varImpPlot(baseRF2, sort = T, n.var = 20, 
           type = 1, main = "Variable Importance Plot without Multicollinearity",
           cex = .8, par(bg = "#2b2420"), color = "white",
           lcolor = "white", pt.cex = 1, col.main = "white", 
           col.lab = "white")

```

### Feature selection for final model

```{asis}
The top twenty features by MSE, Mean Square Error. Variables with a high percentage increase in MSE are considered important. MSE is a metric used to evaluate the performance of regression models, therefore, if a variable with a high percentage increase in MSE is removed from our final model, the model performance will significantly decrease, which is not what we want, hence the variable significance.

Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

importance <- importance(baseRF2)

feature_importance <- data.frame(Feature = rownames(importance), 
                                 Importance = importance[, '%IncMSE'])

impFeatures <- feature_importance %>% 
  arrange(desc(Importance)) %>% 
  head(20)

train_data_final <- train_data_clean %>% 
  select(any_of(impFeatures$Feature), SalePrice)

test_data_final <- test_data_clean %>% 
  select(any_of(impFeatures$Feature), SalePrice)

```

# 6. Modelling

```{asis}
The modelling algorithms I have chosen to use are linear regression, k-nearest neighbors and random forests. Explanations of each of them are given below.

Linear Regression:

lm is a linear modeling technique that assumes a linear relationship between the independent variables and the target variable. It fits a line to the data that minimizes the sum of squared differences between the observed and predicted values. The model is interpretable and provides insights into the impact of each predictor on the target variable through coefficients, however, lm may not capture complex, non-linear relationships present in the data.

k-Nearest Neighbors:

knn is a non-parametric, instance-based algorithm used for both regression and classification tasks. It makes predictions based on the majority class or the average of the values of the k-nearest neighbors to a given data point. The model does not assume any underlying data distribution and can capture non-linear relationships effectively.

Random Forests:

rf is an ensemble learning method that constructs multiple decision trees during training and combines their predictions to make more accurate and robust predictions. Each decision tree in the Random Forests ensemble is trained on a random subset of the training data and a random subset of the features. rf is suitable for both regression and classification tasks and can handle high-dimensional data effectively. It is robust to noise and outliers in the data and can capture complex relationships and interactions between variables.

In summary, Linear Regression is suitable for modeling linear relationships between variables, k-Nearest Neighbors is effective for capturing non-linear relationships and making localized predictions, and Random Forests excel in handling high-dimensional data and capturing complex relationships between variables.
```

## Encode categorical variables for Linear and KNN models

```{r, eval=TRUE, echo=FALSE}

encodeCategorical <- function(x) {
  if (is.factor(x) || is.character(x)) {
    levels <- unique(x)
    numeric_values <- seq_along(levels)
    return(numeric_values[match(x, levels)])
  } else {
    return(x)
  }
}

train_data_final_encoded <- train_data_final %>% 
  mutate(across(everything(), encodeCategorical))

test_data_final_encoded <- test_data_final %>% 
  mutate(across(everything(), encodeCategorical))

```

```{asis}
My models are built around three criteria:

* 1. Models with original SalePrice (no transformation or outlier removal)
* 2. Models with log transformed SalePrice (no outlier removal)
* 3. Models with outlier removal (no transformation)

Please refer to markdown to view code.
```

## Models with original SalesPrice

### Linear Model 1

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
ogSalePrice_lm <- train(SalePrice ~.,
                        data = train_data_final_encoded,
                        method = "lm",
                        trControl = trainControl("cv", number = 10))

```

```{r,eval=FALSE,echo=FALSE}
summary(ogSalePrice_lm)
```

```{asis}
Adjusted R-squared was 0.80 with a RSE of 35100.
```

#### Spread of residuals

##

```{r, eval=TRUE, echo=FALSE}

par(mfrow=c(1,2))
residualPlot(ogSalePrice_lm$finalModel)
hist(ogSalePrice_lm$finalModel$residuals, 
     main = "Histogram of Residuals", 
     xlab="Residuals")
par(mfrow=c(1,1))

```

#### Predictions

```{asis}
Predictions made on linear model. Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}
ogSalePrice_lm_pred <- predict(ogSalePrice_lm, test_data_final_encoded)
```

#### Modify Linear model

```{asis}
Anova to determine significant variables.Please refer to markdown to view code.
```

```{r, eval=FALSE, echo=FALSE}
Anova(ogSalePrice_lm$finalModel, type = 3)
```

### Linear Model 2

```{asis}
Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
ogSalePrice_lm_reduced <- train(SalePrice ~ TotalSquareFeet+Neighborhood+OverallQual
                                +MsSubClass+TotalBathrooms+LotArea+OverallCond
                                +GarageCars+KitchenQual+YearBuilt+BsmtUnfSf+FireplaceQu,
                                data = train_data_final_encoded,
                                method = "lm",
                                trControl = trainControl("cv", number = 10))

```

```{r, eval=FALSE,echo=FALSE}
summary(ogSalePrice_lm_reduced)
```

```{asis}
Adjusted r-squared of 0.80 and RSE of 35620.
```

#### Spread of residuals

##

```{r, eval=TRUE, echo=FALSE}

par(mfrow=c(1,2))
residualPlot(ogSalePrice_lm_reduced$finalModel)
hist(ogSalePrice_lm_reduced$finalModel$residuals, 
     main = "Histogram of Residuals", 
     xlab="Residuals")
par(mfrow=c(1,1))

```

#### Predictions

```{asis}
Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}
ogSalePrice_lm_reduced_pred <- predict(ogSalePrice_lm_reduced, test_data_final_encoded)
```

### KNN Model

```{asis}
Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
ogSalePrice_knn <- train(SalePrice ~.,
                         data = train_data_final_encoded,
                         method = "knn",
                         trControl = trainControl("cv", number = 10),
                         preProcess = c("center", "scale"),
                         tuneLength = 20)

```

```{r,eval=FALSE,echo=FALSE}
ogSalePrice_knn
```

#### Optimal K

##

```{r, eval=TRUE, echo=FALSE}
plot(ogSalePrice_knn)
```

```{asis}
Optimal k selected was k = 11.
```

#### Predictions

```{asis}
Please refer to markdown to view code.
```

````{r, eval=TRUE, echo=FALSE}
ogSalePrice_knn_pred <- predict(ogSalePrice_knn, test_data_final_encoded)
````

### Random Forest Model

```{asis}
Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}

set.seed(123)

tune <- expand.grid(mtry = c(1:20))

ogSalePrice_rf <- train(SalePrice ~.,
                        data = train_data_final,
                        method = "rf",
                        ntree = 100,
                        importance = T,
                        tuneGrid = tune,
                        trControl = trainControl("cv", number = 10))

```

```{r,eval=FALSE,echo=FALSE}
ogSalePrice_rf
```

#### Optimal RMSE

##

```{r, eval=TRUE, echo=FALSE}
plot(ogSalePrice_rf)
```

```{asis}
Final value used for model was mtry = 20.
```

#### Predictions

```{r, eval=TRUE, echo=FALSE}
ogSalePrice_rf_pred <- predict(ogSalePrice_rf, test_data_final)
```

## Models with Log Sales Price

### Histogram of Log Sale Price

```{r,eval=TRUE,echo=FALSE}

hist(log(train_data_final_encoded$SalePrice),
     main = "Histogram of Log Sale Price",
     xlab = "Log Sale Price")

```

```{asis}
Log transformation is normally distributed.
```

### Linear Model 1

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
logSalePrice_lm <- train(log(SalePrice) ~.,
                        data = train_data_final_encoded,
                        method = "lm",
                        trControl = trainControl("cv", number = 10))

```

```{r,echo=FALSE,eval=FALSE}
summary(logSalePrice_lm)
```

```{asis}
Please refer to markdown to view code. Adjusted r-squared was 0.86 with an RSE of 0.1499
```

#### Spread of residuals

##

```{r, eval=TRUE, echo=FALSE}

par(mfrow=c(1,2))
residualPlot(logSalePrice_lm$finalModel)
hist(logSalePrice_lm$finalModel$residuals, 
     main = "Histogram of Residuals", 
     xlab="Residuals")
par(mfrow=c(1,1))

```

#### Predictions

```{asis}
Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}
logSalePrice_lm_pred <- predict(logSalePrice_lm, test_data_final_encoded)
```

#### Modify Linear model

```{asis}
Please refer to markdown to view anova.
```

```{r, eval=FALSE, echo=FALSE}
Anova(logSalePrice_lm$finalModel, type = 3)
```

### Linear Model 2

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
logSalePrice_lm_reduced <- train(log(SalePrice) ~ TotalSquareFeet+OverallQual
                                +MsSubClass+TotalBathrooms+LotArea+OverallCond
                                +GarageCars+YearBuilt+BsmtUnfSf+FireplaceQu,
                                data = train_data_final_encoded,
                                method = "lm",
                                trControl = trainControl("cv", number = 10))

```

```{r, eval=FALSE,echo=FALSE}
summary(logSalePrice_lm_reduced)
```

```{asis}
Please refer to markdown to view code. Asjusted r-squared was 0.86 with an RSE of 0.1513.
```

#### Spread of residuals

##

```{r, eval=TRUE, echo=FALSE}

par(mfrow=c(1,2))
residualPlot(logSalePrice_lm_reduced$finalModel)
hist(logSalePrice_lm_reduced$finalModel$residuals, 
     main = "Histogram of Residuals", 
     xlab="Residuals")
par(mfrow=c(1,1))

```

#### Predictions

```{asis}
Please refer to markdown to view code.
```

```{r, eval=TRUE, echo=FALSE}
logSalePrice_lm_reduced_pred <- predict(logSalePrice_lm_reduced, test_data_final_encoded)
```

### KNN Model

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
logSalePrice_knn <- train(log(SalePrice) ~.,
                         data = train_data_final_encoded,
                         method = "knn",
                         trControl = trainControl("cv", number = 10),
                         preProcess = c("center", "scale"),
                         tuneLength = 20)

```

```{r,eval=FALSE,echo=FALSE}
logSalePrice_knn
```

```{asis}
Please refer to markdown to view code.
```

#### Optimal K

##

```{r, eval=TRUE, echo=FALSE}
plot(logSalePrice_knn)
```

```{asis}
Optimal k selected was k = 5.
```

#### Predictions

```{asis}
Please refer to markdown to view code.
```

````{r, eval=TRUE, echo=FALSE}
logSalePrice_knn_pred <- predict(logSalePrice_knn, test_data_final_encoded)
````

### Random Forest Model

```{r, eval=TRUE, echo=FALSE}

set.seed(123)

tune <- expand.grid(mtry = c(1:20))

logSalePrice_rf <- train(log(SalePrice) ~.,
                        data = train_data_final,
                        method = "rf",
                        ntree = 100,
                        importance = T,
                        tuneGrid = tune,
                        trControl = trainControl("cv", number = 10))

```

```{r,eval=FALSE,echo=FALSE}
logSalePrice_rf
```

```{asis}
Please refer to markdown to view code.
```

#### Optimal RMSE

##

```{r, eval=TRUE, echo=FALSE}
plot(logSalePrice_rf)
```

```{asis}
Final value used for the model was mtry = 18.
```

#### Predictions

```{r, eval=TRUE, echo=FALSE}
logSalePrice_rf_pred <- predict(logSalePrice_rf, test_data_final)
```

## Models with Sales Price outliers removed

### Outlier Detection for LM and KNN

```{asis}
Outliers identified and removed.

Please refer to markdown for code.
```

```{r, eval=TRUE, echo=FALSE}
# Detect outliers based on the interquartile range (IQR)
trainQ1 <- quantile(train_data_final_encoded$SalePrice, 0.25)
trainQ3 <- quantile(train_data_final_encoded$SalePrice, 0.75)
trainIQR <- trainQ3 - trainQ1
train_lower_bound <- trainQ1 - 1.5 * trainIQR
train_upper_bound <- trainQ3 + 1.5 * trainIQR

# Identify indices of outliers
train_outlier_indices <- which(train_data_final_encoded$SalePrice < train_lower_bound | 
                           train_data_final_encoded$SalePrice > train_upper_bound)

train_data_final_encodedNO <- train_data_final_encoded[-train_outlier_indices, ]

# Detect outliers based on the interquartile range (IQR)
testQ1 <- quantile(test_data_final_encoded$SalePrice, 0.25)
testQ3 <- quantile(test_data_final_encoded$SalePrice, 0.75)
testIQR <- testQ3 - testQ1
test_lower_bound <- testQ1 - 1.5 * testIQR
test_upper_bound <- testQ3 + 1.5 * testIQR

# Identify indices of outliers
test_outlier_indices <- which(test_data_final_encoded$SalePrice < test_lower_bound | 
                           test_data_final_encoded$SalePrice > test_upper_bound)

test_data_final_encodedNO <- test_data_final_encoded[-test_outlier_indices, ]

```

### Outlier Detection for Random Forest

```{asis}
Outliers identified and removed.

Please refer to markdown for code.
```

```{r,eval=TRUE,echo=FALSE}

# Detect outliers based on the interquartile range (IQR)
trainQ1 <- quantile(train_data_final$SalePrice, 0.25)
trainQ3 <- quantile(train_data_final$SalePrice, 0.75)
trainIQR <- trainQ3 - trainQ1
train_lower_bound <- trainQ1 - 1.5 * trainIQR
train_upper_bound <- trainQ3 + 1.5 * trainIQR

# Identify indices of outliers
train_outlier_indices <- which(train_data_final$SalePrice < train_lower_bound | 
                           train_data_final$SalePrice > train_upper_bound)

train_data_finalNO <- train_data_final[-train_outlier_indices, ]

# Detect outliers based on the interquartile range (IQR)
testQ1 <- quantile(test_data_final$SalePrice, 0.25)
testQ3 <- quantile(test_data_final$SalePrice, 0.75)
testIQR <- testQ3 - testQ1
test_lower_bound <- testQ1 - 1.5 * testIQR
test_upper_bound <- testQ3 + 1.5 * testIQR

# Identify indices of outliers
test_outlier_indices <- which(test_data_final$SalePrice < test_lower_bound | 
                           test_data_final$SalePrice > test_upper_bound)

test_data_finalNO <- test_data_final[-test_outlier_indices, ]

```

### Distribution of SalePrice without outliers

```{r eval=TRUE,echo=FALSE}

ggplot(train_data_final_encodedNO, aes(x="", y=SalePrice)) +
  geom_boxplot(col = "white", outlier.color = "green", 
               outlier.shape = 20, outlier.size = 2) +
  stat_summary(fun="mean",
               geom="point",
               color="blue",
               fill="blue",
               size=3,
               shape=20) +
  labs(title = "Boxplot of Sale Price (Extreme outliers removed)", 
       x = " ", y = "Sale price") +
  scale_y_continuous(name = "Sale Price (USD)", labels = scales::comma) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      axis.title.x = element_text(size = 12, hjust = 0.5),
      axis.title.y = element_text(size = 12, hjust = 0.5)) 

```

```{asis}
Extreme outliers have been removed.
```

### Linear Model 1

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
SalePrice_noOut_lm <- train(SalePrice ~.,
                        data = train_data_final_encodedNO,
                        method = "lm",
                        trControl = trainControl("cv", number = 10))

```

```{r,echo=FALSE,eval=FALSE}
summary(SalePrice_noOut_lm)
```

```{asis}
Please refer to markdown for code.
Adjusted r-squared was 0.81 with an RSE of 25590.
```

#### Spread of residuals

##

```{r, eval=TRUE, echo=FALSE}

par(mfrow=c(1,2))
residualPlot(SalePrice_noOut_lm$finalModel)
hist(SalePrice_noOut_lm$finalModel$residuals, 
     main = "Histogram of Residuals", 
     xlab="Residuals")
par(mfrow=c(1,1))

```

#### Predictions

```{asis}
Please refer to markdown for code.
```

```{r, eval=TRUE, echo=FALSE}
SalePrice_noOut_lm_pred <- predict(SalePrice_noOut_lm, test_data_final_encodedNO)
```

#### Modify Linear model

```{asis}
Please refer to markdown for anova.
```

```{r, eval=FALSE, echo=FALSE}
Anova(SalePrice_noOut_lm$finalModel, type = 3)
```

### Linear Model 2

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
SalePrice_noOut_lm_reduced <- train(SalePrice ~ TotalSquareFeet+Neighborhood+OverallQual
                                +MsSubClass+TotalBathrooms+LotArea+ExterQual+OverallCond
                                +GarageCars+YearBuilt+BsmtUnfSf+FireplaceQu,
                                data = train_data_final_encodedNO,
                                method = "lm",
                                trControl = trainControl("cv", number = 10))

```

```{r,eval=FALSE,echo=FALSE}
summary(SalePrice_noOut_lm_reduced)
```

```{asis}
Please refer to markdown for code. Adjusted r-squared was 0.81 with an RSE of 25830.
```

#### Spread of residuals

##

```{r, eval=TRUE, echo=FALSE}

par(mfrow=c(1,2))
residualPlot(SalePrice_noOut_lm_reduced$finalModel)
hist(SalePrice_noOut_lm_reduced$finalModel$residuals, 
     main = "Histogram of Residuals", 
     xlab="Residuals")
par(mfrow=c(1,1))

```

#### Predictions

```{asis}
Please refer to markdown for code.
```

```{r, eval=TRUE, echo=FALSE}
SalePrice_noOut_lm_reduced_pred <- predict(SalePrice_noOut_lm_reduced,
                                           test_data_final_encodedNO)
```

### KNN Model

```{asis}
Please refer to markdown for code.
```

```{r, eval=TRUE, echo=FALSE}

set.seed(123)
SalePrice_noOut_knn <- train(SalePrice ~.,
                         data = train_data_final_encodedNO,
                         method = "knn",
                         trControl = trainControl("cv", number = 10),
                         preProcess = c("center", "scale"),
                         tuneLength = 20)
```

```{r,eval=FALSE,echo=FALSE}
SalePrice_noOut_knn
```

#### Optimal K

##

```{r, eval=TRUE, echo=FALSE}
plot(SalePrice_noOut_knn)
```

```{asis}
Optimal k selected was k = 7.
```

#### Predictions

```{asis}
Please refer to markdown for code.
```

````{r, eval=TRUE, echo=FALSE}
SalePrice_noOut_knn_pred <- predict(SalePrice_noOut_knn, test_data_final_encodedNO)
````

### Random Forest Model

```{asis}
Please refer to markdown for code.
```

```{r, eval=TRUE, echo=FALSE}

set.seed(123)

tune <- expand.grid(mtry = c(1:20))

SalePrice_noOut_rf <- train(SalePrice ~.,
                        data = train_data_finalNO,
                        method = "rf",
                        ntree = 100,
                        importance = T,
                        tuneGrid = tune,
                        trControl = trainControl("cv", number = 10))
```

```{r,eval=FALSE,echo=FALSE}
SalePrice_noOut_rf
```

#### Optimal RMSE

## 

```{r, eval=TRUE, echo=FALSE}
plot(SalePrice_noOut_rf)
```

```{asis}
Final value selected for model was mtry = 20.
```

#### Predictions

```{asis}
Please refer to markdown for code.
```

```{r, eval=TRUE, echo=FALSE}
SalePrice_noOut_rf_pred <- predict(SalePrice_noOut_rf, test_data_finalNO)
```

# 7. Evaluation

```{asis}
In this section I compare model performance using metrics RMSE, MAE and R-squared.

An explanation of them is given below:

Root Mean Squared Error (RMSE):

RMSE measures the average magnitude of the errors between the predicted values and the actual values. It is calculated by taking the square root of the average of the squared differences between the predicted and actual values. RMSE gives higher weight to large errors, making it sensitive to outliers. Lower RMSE values indicate better model performance, with a value of 0 indicating perfect predictions.

Mean Absolute Error (MAE):

MAE measures the average absolute difference between the predicted values and the actual values. It is calculated by taking the average of the absolute differences between the predicted and actual values. MAE is less sensitive to outliers compared to RMSE since it does not square the errors. Like RMSE, lower MAE values indicate better model performance.

R-squared (R2):

R2 represents the proportion of the variance in the dependent variable that is explained by the independent variables in the model. It ranges from 0 to 1, with higher values indicating a better fit of the model to the data. R2 of 1 indicates that the model explains all the variability in the data, while an R2 of 0 indicates that the model does not explain any variability. R2 is a measure of how well the model fits the data relative to a simple average of the dependent variable.

```

## Models with original Sale Price (Evaluation)

```{r,eval=TRUE,echo=FALSE}

ogSalePrice_lm_sum <- data.frame(RMSE = RMSE(ogSalePrice_lm_pred,
                                                    test_data_final_encoded$SalePrice),
                                        MAE = MAE(ogSalePrice_lm_pred,
                                                  test_data_final_encoded$SalePrice),
                                        R2 = caret::R2(ogSalePrice_lm_pred,
                                                       test_data_final_encoded$SalePrice))

ogSalePrice_lm_reduced_sum <- data.frame(RMSE = RMSE(ogSalePrice_lm_reduced_pred,
                                                    test_data_final_encoded$SalePrice),
                                        MAE = MAE(ogSalePrice_lm_reduced_pred,
                                                  test_data_final_encoded$SalePrice),
                                        R2 = caret::R2(ogSalePrice_lm_reduced_pred,
                                                       test_data_final_encoded$SalePrice))

ogSalePrice_knn_sum <- data.frame(RMSE = RMSE(ogSalePrice_knn_pred,
                                                    test_data_final_encoded$SalePrice),
                                        MAE = MAE(ogSalePrice_knn_pred,
                                                  test_data_final_encoded$SalePrice),
                                        R2 = caret::R2(ogSalePrice_knn_pred,
                                                       test_data_final_encoded$SalePrice))

ogSalePrice_rf_sum <- data.frame(RMSE = RMSE(ogSalePrice_rf_pred,
                                                    test_data_final$SalePrice),
                                        MAE = MAE(ogSalePrice_rf_pred,
                                                  test_data_final$SalePrice),
                                        R2 = caret::R2(ogSalePrice_rf_pred,
                                                       test_data_final$SalePrice))

```

```{r,eval=TRUE,echo=FALSE}

eval1 <- rbind(ogSalePrice_lm_sum,
              ogSalePrice_lm_reduced_sum,
              ogSalePrice_knn_sum,
              ogSalePrice_rf_sum)

rownames(eval1) <- c("Linear","Linear Reduced","KNN","Random Forest")

knitr::kable(eval1)

```

## Models with Log Sale Price (Evaluation)

```{r,eval=TRUE,echo=FALSE}

logSalePrice_lm_sum <- data.frame(RMSE = RMSE(exp(logSalePrice_lm_pred),
                                                  test_data_final_encoded$SalePrice),
                                        MAE = MAE(exp(logSalePrice_lm_pred),
                                                  test_data_final_encoded$SalePrice),
                                        R2 = caret::R2(exp(logSalePrice_lm_pred),
                                                       test_data_final_encoded$SalePrice))

logSalePrice_lm_reduced_sum <- data.frame(RMSE = RMSE(exp(logSalePrice_lm_reduced_pred),
                                                    test_data_final_encoded$SalePrice),
                                        MAE = MAE(exp(logSalePrice_lm_reduced_pred),
                                                  test_data_final_encoded$SalePrice),
                                        R2 = caret::R2(exp(logSalePrice_lm_reduced_pred),
                                                       test_data_final_encoded$SalePrice))

logSalePrice_knn_sum <- data.frame(RMSE = RMSE(exp(logSalePrice_knn_pred),
                                                    test_data_final_encoded$SalePrice),
                                        MAE = MAE(exp(logSalePrice_knn_pred),
                                                  test_data_final_encoded$SalePrice),
                                        R2 = caret::R2(exp(logSalePrice_knn_pred),
                                                       test_data_final_encoded$SalePrice))

logSalePrice_rf_sum <- data.frame(RMSE = RMSE(exp(logSalePrice_rf_pred),
                                                    test_data_final$SalePrice),
                                        MAE = MAE(exp(logSalePrice_rf_pred),
                                                  test_data_final$SalePrice),
                                        R2 = caret::R2(exp(logSalePrice_rf_pred),
                                                       test_data_final$SalePrice))

```

```{r,eval=TRUE,echo=FALSE}

eval2 <- rbind(logSalePrice_lm_sum,
              logSalePrice_lm_reduced_sum,
              logSalePrice_knn_sum,
              logSalePrice_rf_sum)

rownames(eval2) <- c("Linear","Linear Reduced","KNN","Random Forest")

knitr::kable(eval2)

```

## Models with Sale Price outliers removed (Evaluation)

```{r,eval=TRUE,echo=FALSE}

SalePrice_noOut_lm_sum <- data.frame(RMSE = RMSE(SalePrice_noOut_lm_pred,
                                                  test_data_final_encodedNO$SalePrice),
                                        MAE = MAE(SalePrice_noOut_lm_pred,
                                                  test_data_final_encodedNO$SalePrice),
                                        R2 = caret::R2(SalePrice_noOut_lm_pred,
                                                       test_data_final_encodedNO$SalePrice))

SalePrice_noOut_lm_reduced_sum <- data.frame(RMSE = RMSE(SalePrice_noOut_lm_reduced_pred,
                                                    test_data_final_encodedNO$SalePrice),
                                        MAE = MAE(SalePrice_noOut_lm_reduced_pred,
                                                  test_data_final_encodedNO$SalePrice),
                                        R2 = caret::R2(SalePrice_noOut_lm_reduced_pred,
                                                       test_data_final_encodedNO$SalePrice))

SalePrice_noOut_knn_sum <- data.frame(RMSE = RMSE(SalePrice_noOut_knn_pred,
                                                    test_data_final_encodedNO$SalePrice),
                                        MAE = MAE(SalePrice_noOut_knn_pred,
                                                  test_data_final_encodedNO$SalePrice),
                                        R2 = caret::R2(SalePrice_noOut_knn_pred,
                                                       test_data_final_encodedNO$SalePrice))

SalePrice_noOut_rf_sum <- data.frame(RMSE = RMSE(SalePrice_noOut_rf_pred,
                                                    test_data_finalNO$SalePrice),
                                        MAE = MAE(SalePrice_noOut_rf_pred,
                                                  test_data_finalNO$SalePrice),
                                        R2 = caret::R2(SalePrice_noOut_rf_pred,
                                                       test_data_finalNO$SalePrice))

```

```{r,eval=TRUE,echo=FALSE}

eval3 <- rbind(SalePrice_noOut_lm_sum,
              SalePrice_noOut_lm_reduced_sum,
              SalePrice_noOut_knn_sum,
              SalePrice_noOut_rf_sum)

rownames(eval3) <- c("Linear","Linear Reduced","KNN","Random Forest")

knitr::kable(eval3)

```

## Average RMSE of Model Categories

```{r, eval=TRUE, echo=FALSE}
eval4 <- data.frame(Mean_RMSE = c(mean(eval1$RMSE),
                                  mean(eval2$RMSE),
                                  mean(eval3$RMSE)))

rownames(eval4) <- c("Models with original SalePrice",
                     "Models with Log SalePrice",
                     "Models with SalePrice no outliers")

knitr::kable(eval4)
```

```{asis}
Models that were built on SalePrice without outliers on average performed best. Moving forward, model performance can be improved upon with outlier removal as a baseline.
```

## Trend of Predicted and Observed Sale Prices

```{r,eval=TRUE,echo=FALSE}

test_data_copy <- test_data

################# Clean Copy
# Detect outliers based on the interquartile range (IQR)
testQ1 <- quantile(test_data_copy$SalePrice, 0.25)
testQ3 <- quantile(test_data_copy$SalePrice, 0.75)
testIQR <- testQ3 - testQ1
test_lower_bound <- testQ1 - 1.5 * testIQR
test_upper_bound <- testQ3 + 1.5 * testIQR

# Identify indices of outliers
test_outlier_indices <- which(test_data_copy$SalePrice < test_lower_bound | 
                           test_data_copy$SalePrice > test_upper_bound)

test_data_copy <- test_data_copy[-test_outlier_indices, ]
###########################################################

#####################################################plot fitted copy
fittedCopy <- test_data_finalNO 
fittedCopy$PredictedSalePrice <- SalePrice_noOut_rf_pred
fittedCopy$YrSold <- test_data_copy$YrSold

combinedStats2 <- fittedCopy %>% 
  group_by(YrSold) %>% 
  summarise(meanPrice = round(mean(SalePrice)),
            meanPredictedPrice = round(mean(PredictedSalePrice)),
            medianPrice = round(median(SalePrice)),
            medianPredictedPrice = round(median(PredictedSalePrice)))

ggplot(combinedStats2, aes(x = as.factor(YrSold))) +
  geom_point(aes(y = meanPrice, col = "Mean")) +
  geom_line(aes(y = meanPrice, col = "Mean"), group = 1) +
  geom_point(aes(y = meanPredictedPrice, col = "PredictedMean")) +
  geom_line(aes(y = meanPredictedPrice, col = "PredictedMean"), group = 1) +
  geom_point(aes(y = medianPrice, col = "Median")) +
  geom_line(aes(y = medianPrice, col = "Median"), group = 1) +
  geom_point(aes(y = medianPredictedPrice, col = "PredictedMedian")) +
  geom_line(aes(y = medianPredictedPrice, col = "PredictedMedian"), group = 1) +
  labs(title = "Trend of Predicted and Observed Sale Prices",
       y = "Sale Price (USD)",
       x = "Year") +
  scale_color_manual("Legend", values = c("Mean"="red",
                                          "PredictedMean" = "#6C613B",
                                          "PredictedMedian" = "#790469",
                                          "Median"="turquoise")) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        axis.title.x = element_text(size = 12, hjust = 0.5),
        axis.title.y = element_text(size = 12, hjust = 0.5),
        legend.position = "bottom",
        axis.text.x = element_text(vjust = 1, size = 8))

```

```{asis}
The plot above is a replica of the Median/Mean sale price over time but with the predicted values of the best model. Best model picked was the random forest with no outliers in sales price.

Predicted values show very similar pattern to observed values, ie, predicted mean is higher than predicted median.
```

# 8. Recommendations and Conclusions

```{asis}
Key findings from my analysis:

Rigourus data pre-processing proved worthwhile as models with low RMSE and high accuracy were produced. Maintaining the data pipeline was particularly challenging because consistency had to ensured between both train and test sets. Not remembering to mirror pre-processing across both datasets can improve very costly and time confusing to fix when working up the pipeline.

EDAs highlighted that Saleprice had strong correlations with neighbourhood and overall quality. More variables could have been plotted to check their correlation however I was most interested in these two variables because those are the factors most home buyers consider when looking for a new home; the neighbourhood/suburb of the property and its build quality, hence it seemed more worthwhile to study them.

Outlier removal definitely had a strong impact on model performance. The best RMSE obtained was a random forest model trained on datasets without outliers. The variables used were the significant variables determined from earlier random forest models. This proved particularly useful in achieving dimensionality reduction and improving model performance.

Improvements that can be made to models:

* Feature engineer more variables:

LandValue and SeasonSold. Land value can be used to study correlation on the value of land the property is built on with sale price. I imagine a number of metrics will have to be taken into account to determine land value include neighbourhood, recreational areas around the lans, commercial areas around the land, demographics around the land etc. Scaling all these metrics into a number that can be assigned as land value would be challenging as well.

SeasonSold can be used to study the finer details between saleprice vs season and number of sales vs season. The time series plot I made already captures most trends but it would be more insightful if the trends were broken down into seasons.

* Build more models:

More models could definitely be built. One such example would be training a models with a combination of log sale price and outlier remova. I expect this would produce very low rmse values since outlier removal on its own already significantly improves model performance. A stricter ANOVA selection could be done when reducing linear models. The five most significant variables from ANOVA could be selected and used on the reduced model. I expect this to produce better rmse values for the linear models. Since linear regression struggles with complex dimensions, strictly reducing dimensions while not straying far away from significance should produce considerably better results. Furthermore, more advanced models such as neural networks could be trained and evaluated.

* Useful findigs:

* Package "ggthemr" for the aesthetics and produce better looking plots.
* plot_missing function was particularly useful in visualising the proportion of missing values.
* Random forests for variable importance made feature selection a lot more efficient.
* Density plots were used as an alternative to histograms where bin and bin-width selection were difficult to determine.

Overall, from my plots and models, you can make recommendations on affordable/expensive neighbourhoods, have an estimate of saleprice on home age, overall quality, totalbathrooms etc, and know which seasons are more affordable to buy a home.
```

# 9. References

```{asis}
Boykin, R. (2023) How seasons impact real estate investments, Investopedia. Available at: https://www.investopedia.com/articles/investing/010717/seasons-impact-real-estate-more-you-think.asp (Accessed: 08 May 2024). 

Great recession: What it was and what caused it (2023) Investopedia. Available at: https://www.investopedia.com/terms/g/great-recession.asp#:~:text=The%20economic%20slump%20began%20when,and%20derivatives%20plummeted%20in%20value. (Accessed: 08 May 2024). 

Research guides: This Month in business history: The panic of 1873 (2021) The Panic of 1873 - This Month in Business History - Research Guides at Library of Congress. Available at: https://guides.loc.gov/this-month-in-business-history/september/panic-of-1873#:~:text=The%20Panic%20of%201873%20triggered,stock%20market%20crash%20of%201929. (Accessed: 08 May 2024). 
```


***

























