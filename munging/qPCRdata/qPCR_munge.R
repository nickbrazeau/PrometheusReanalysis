## .................................................................................
## Purpose: Tidy up qPCR data from Woods and NHS
##
## Author: Nick Brazeau
##
## Notes:
## .................................................................................
library(tidyverse)
library(readxl)
library(pheatmap)

#++++++++++++++++++++++++++++++++++++++++++
### Section 0:  Import Raw Data        ####
#++++++++++++++++++++++++++++++++++++++++++
nhs <- readxl::read_excel("data/raw/qPCRdata/NHS_PCR_results_Dates.xlsx")
woods <- readxl::read_excel("data/raw/qPCRdata/Prometheus_qpcr_data_CLEANv1.3.xlsx", sheet = 1)

#++++++++++++++++++++++++++++++++++++++++++
### Section 1: Tidy Up   ####
#++++++++++++++++++++++++++++++++++++++++++
#.........
# Find Subjects with Viral Innoculum on Multiple Repeats
#.........
rws <- woods %>%
  dplyr::select(-c("Subject_ID", "D-1", "...14"))
kp <- apply(rws > 0, 1, sum) # rows with viral innoculum
kp <- kp > 2
woods_comb <- woods %>%
  dplyr::select(-c("...14")) %>%
  dplyr::mutate(Woods_qPCR = kp)

#.........
# NHS Data
#.........
nhs2 <- nhs %>%
  dplyr::select(-c("DATE")) %>%
  dplyr::rename(Subject_ID = ID,
                NHS_qPCR = RESULT) %>%
  dplyr::mutate(NHS_qPCR = ifelse(NHS_qPCR == "Negative", FALSE,
                                  ifelse(NHS_qPCR == "Positive", TRUE, NA)))

#.........
# Combine
#.........
qPCR_derived <- dplyr::left_join(woods_comb, nhs2, by = "Subject_ID")

#++++++++++++++++++++++++++++++++++++++++++
### Section 2: Write Out Derived    ####
#++++++++++++++++++++++++++++++++++++++++++

saveRDS(qPCR_derived, file = "data/derived/qPCRdata/qPCR_derived.RDS")

