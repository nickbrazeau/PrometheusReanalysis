## .................................................................................
## Purpose: Tidy up Cytokine raw data into usable format
##
## Author: Nick Brazeau
##
## Date: 18 April, 2026
##
## Notes:
## .................................................................................
library(tidyverse)
library(readxl)

#++++++++++++++++++++++++++++++++++++++++++
### Section 0:  Import Raw Data        ####
#++++++++++++++++++++++++++++++++++++++++++
dat <- readxl::read_excel("data/raw/HAI_results/PROMETHEUS_Outcome_HAI.xlsx",
                          sheet = 2, skip = 3)
key <- readr::read_csv("munging/HAI/HAI_key.csv")


#++++++++++++++++++++++++++++++++++++++++++
### Section 1:  Munge Raw Data        ####
#++++++++++++++++++++++++++++++++++++++++++
datclean <- dplyr::left_join(dat, key, by = "Order") %>%
  dplyr::select(-c("Order")) %>%
  dplyr::select(c("Subject ID"), dplyr::everything())
colnames(datclean) <- c("PID", "HAI_D0", "HAI_D28", "HAI_D180")

datclean <- datclean %>%
  dplyr::mutate(HAI_D180 = dplyr::na_if(HAI_D180, "No sample"),
                HAI_D180 = dplyr::na_if(HAI_D180, "Didn't run sample"))

# tidy up for seroconversion
datclean_num <- datclean %>%
  dplyr::mutate(HAI_D0 = purrr::map_chr(HAI_D0, function(x){ifelse(x == "<1:10", "5", x)}),
                HAI_D28 = purrr::map_chr(HAI_D28, function(x){ifelse(x == "<1:10", "5", x)}),
                HAI_D180 = purrr::map_chr(HAI_D180, function(x){ifelse(x == "<1:10", "5", x)}),
                HAI_D0 = as.numeric( stringr::str_replace(HAI_D0, "1:", "") ),
                HAI_D28 = as.numeric( stringr::str_replace(HAI_D28, "1:", "") ),
                HAI_D180 = as.numeric( stringr::str_replace(HAI_D180, "1:", "") )
                )

# state seroconversion
# Def: if baseline, <1:10 and they have >1:40 at D28 - or - 4-fold increase from baseline

datclean_num <- datclean_num %>%
  dplyr::mutate(seroconversion = purrr::map2_lgl(HAI_D0, HAI_D28, function(x,y){
           ifelse(x == 5 & y >= 40, TRUE,
                  ifelse(y/x >=4 & y >= 40, TRUE, FALSE))})) %>%
  dplyr::select(c("PID", "seroconversion"))




#++++++++++++++++++++++++++++++++++++++++++
### Section 2: Write Out Derived    ####
#++++++++++++++++++++++++++++++++++++++++++
dplyr::left_join(datclean, datclean_num, by = "PID") %>%
  saveRDS(., file = "data/derived/HAI_results/HAI_seroconversion.RDS")

