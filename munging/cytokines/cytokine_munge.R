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
library(pheatmap)
source("R/themes.R")

#++++++++++++++++++++++++++++++++++++++++++
### Section 0:  Import Raw Data        ####
#++++++++++++++++++++++++++++++++++++++++++
batch1 <- readxl::read_excel(path = "data/raw/cytokines/Burke_SR168_FinalData_050718.xls",
                             skip = 1) %>%
  dplyr::select(-c("Sample #", "Plate Number", "SampleType")) %>%
  dplyr::rename(`Participant ID` = `Subject ID`)

batch2 <- readxl::read_excel(path = "data/raw/cytokines/Burke_SR168_Part2_FinalData_07232018.xlsx",
                             skip = 1) %>%
  dplyr::select(-c("SampleNumber", "Sample Type",
                   "Current Amount and Units", "Plate"))
#......................
# bring together
#......................
cytokinedata <- dplyr::bind_rows(batch1, batch2) %>%
  dplyr::select(-c("Sample ID")) %>%
  dplyr::rename(PID = `Participant ID`)
# fix colnames
colnames(cytokinedata) <- gsub("Final ", "", colnames(cytokinedata))
colnames(cytokinedata) <- gsub(" \\(pg/ml\\)", "", colnames(cytokinedata))
# fix time point
cytokinedata <- cytokinedata %>%
  dplyr::mutate(Timepoint = stringr::str_split_fixed(Timepoint, " \\(", n=2)[,1]) %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = c("Day -1", "Day 0",
                                                         "Day 1", "Day 2", "Day 3")))

#++++++++++++++++++++++++++++++++++++++++++
### Section 1: Log2 Transformations    ####
#++++++++++++++++++++++++++++++++++++++++++
#' @title Internal Function to Manually lift over the Cytokine Data with a log2
#' transformation
#' @returns log2-based table
#' @export
log2transformer <- function(cytokinedata) {

  #..................................
  # setup (const, storage, etc)
  #.................................
  log2cytokines <- data.frame()
  cytlist <- cytokinedata %>%
    dplyr::arrange(PID, Timepoint) %>%
    split(., f = factor(.$PID))

  #..................................
  # core
  #..................................

  for(i in 1:length(cytlist)) {

    # check that this is OK to do manually
    if(!all(
      cytlist[[i]]$Timepoint %in% c("Day -1", "Day 0", "Day 1", "Day 2", "Day 3"),
      cytlist[[i]]$Timepoint[1] == "Day -1",
      cytlist[[i]]$Timepoint[2] == "Day 0",
      cytlist[[i]]$Timepoint[3] == "Day 1",
      cytlist[[i]]$Timepoint[4] == "Day 2",
      cytlist[[i]]$Timepoint[5] == "Day 3"
    )){
      errorCondition("Unordered cytokine data, cant do this")
    }

    # manual liftover
    tempdf <- cytlist[[i]]
    d0 <- log2( tempdf[2, 3:ncol(tempdf)] / tempdf[1, 3:ncol(tempdf)])
    d1 <- log2( tempdf[3, 3:ncol(tempdf)] / tempdf[1, 3:ncol(tempdf)])
    d2 <- log2( tempdf[4, 3:ncol(tempdf)] / tempdf[1, 3:ncol(tempdf)])
    d3 <- log2( tempdf[5, 3:ncol(tempdf)] / tempdf[1, 3:ncol(tempdf)])

    # now combine
    tempdf <- dplyr::bind_cols(tempdf[2:5,1:2], dplyr::bind_rows(d0, d1, d2, d3))

    # now add on
    log2cytokines <- dplyr::bind_rows(log2cytokines, tempdf)
  }

  return(log2cytokines)
}


#++++++++++++++++++++++++++++++++++++++++++
### Section 2: Write Out Derived    ####
#++++++++++++++++++++++++++++++++++++++++++
cytokinedata_transformed <- log2transformer(cytokinedata)
saveRDS(cytokinedata_transformed, file = "data/derived/cytokines/cytokinedata_log2transformed.RDS")



#............................................................
# EDA
#...........................................................
ncol(cytokinedata_transformed)

cytokinedata_transformed %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

#++++++++++++++++++++++++++++++++++++++++++
### Section 3: Imputation    ####
#++++++++++++++++++++++++++++++++++++++++++
@@@
