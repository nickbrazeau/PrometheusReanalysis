## .................................................................................
## Purpose: Analyze Cytokine Data
##
## Author: Nick Brazeau
##
## Notes:
## .................................................................................
library(tidyverse)
source("R/themes.R")


#++++++++++++++++++++++++++++++++++++++++++
### Section 0: Read Data   ####
#++++++++++++++++++++++++++++++++++++++++++
# cytokine
plasma_cytokinedata_transformed <- readRDS("data/derived/cytokines/plasma_cytokinedata_log2transformed.RDS")
# PCR
qPCR_derived <- readRDS("data/derived/qPCRdata/qPCR_derived.RDS") %>%
  dplyr::rename(PID = Subject_ID) %>%
  dplyr::select(c("PID", "Woods_qPCR", "NHS_qPCR", dplyr::everything())) %>%
  tidyr::pivot_longer(data = ., cols = dplyr::starts_with("D"),
                      names_to = "Timepoint",
                      values_to = "qPCR_Ct") %>%
  dplyr::mutate(Timepoint = stringr::str_replace(Timepoint, "\\bD(?=\\d)", "Day "))
# HAI
hai_derived <- readRDS("data/derived/HAI_results/HAI_seroconversion.RDS")


#.....................
# QC
#...................
msngness <- is.na(plasma_cytokinedata_transformed)
image(msngness)
keep <- colSums(msngness)/nrow(msngness) < 0.40 # less than 40% missing
plasma_cytokinedata_transformed <- plasma_cytokinedata_transformed[, keep]

# library(dplyr); library(tidyr); library(ggplot2)
#
# miss_df <- df %>%
#   summarise(across(everything(), ~ mean(is.na(.x)))) %>%
#   pivot_longer(everything(), names_to = "variable", values_to = "prop_missing")
#
# ggplot(miss_df, aes(x = reorder(variable, prop_missing), y = prop_missing)) +
#   geom_col(fill = "steelblue") +
#   geom_text(aes(label = scales::percent(prop_missing, accuracy = 0.1)),
#             hjust = -0.1, size = 3) +
#   coord_flip() +
#   scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
#   labs(x = NULL, y = "Proportion missing", title = "Missingness by variable") +
#   theme_minimal()


#.....................
# Combined
#...................
qPCR_derived_PCR <- qPCR_derived %>%
  dplyr::select(-c("Woods_qPCR", "NHS_qPCR"))

qPCR_derived_ret <- qPCR_derived %>%
  dplyr::select(c("PID", "Woods_qPCR", "NHS_qPCR")) %>%
  dplyr::filter(!duplicated(PID))

datacomm <- dplyr::full_join(plasma_cytokinedata_transformed, qPCR_derived_PCR,
                             by = c("PID", "Timepoint")) %>%
  dplyr::left_join(., qPCR_derived_ret, by = "PID") %>%
  dplyr::mutate(PCRpos = ifelse(NHS_qPCR == T | Woods_qPCR == T, T, F)) %>%
  dplyr::left_join(., hai_derived, by = "PID")



#++++++++++++++++++++++++++++++++++++++++++
### Section 1: Cytokine All   ####
#++++++++++++++++++++++++++++++++++++++++++
# all w/o mtdt
plasma_cytokinedata_transformed %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p0

# all with mtdt
p1 <- datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PCRpos), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
    scale_color_discrete(palette = c("#B80303", "#163B92")) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p1

p1_sig <- datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  dplyr::filter(cytokine %in% c(
    "Eotaxin", "Eotaxin-3", "IFN-γ", "IL-10", "IL-12", "IL-15", "IL-1a", "IL-6", "IP-10", "MCP-1", "MDC","MIP-1α", "MIP-1β", "TNF-α")) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PCRpos), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  scale_color_discrete(palette = c("#B80303", "#163B92")) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p1_sig


p1_sig <- datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  dplyr::filter(cytokine %in% c(
    "IFN-γ", "IL-10", "IL-12", "IL-15", "IP-10", "TNF-α")) %>%
  dplyr::filter(seroconversion == T) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p1_sig

#++++++++++++++++++++++++++++++++++++++++++
### Section 2: Cytokine vs qPCR / HAI   ####
#++++++++++++++++++++++++++++++++++++++++++

# all with woods
p2 <- datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = Woods_qPCR), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
    scale_color_discrete(palette = c("#B80303", "#163B92")) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))
p2

p3 <- datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = seroconversion), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  scale_color_discrete(palette = c("#C48156", "#3EB952")) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))
p3

#++++++++++++++++++++++++++++++++++++++++++
### Section 2: Cytokines Aggregate  ####
#++++++++++++++++++++++++++++++++++++++++++
p4 <- datacomm %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", 0:3))) %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::group_by(PCRpos, Timepoint, cytokine) %>%
  dplyr::summarise(
    n = dplyr::n(),
    mean = mean(log2foldchange, na.rm = T),
    sd = sd(log2foldchange, na.rm = T),
    L95 = mean - 1.96*(sd/sqrt(n)),
    U95 = mean + 1.96*(sd/sqrt(n))) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = mean, group = PCRpos, linetype = PCRpos, color = PCRpos)) +
  geom_pointrange(aes(x = Timepoint, xmin = Timepoint, xmax = Timepoint,
                      y = mean, ymin = L95, ymax = U95,
                      color = PCRpos), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
    scale_color_discrete(palette = c("#B80303", "#163B92")) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p4

p5 <- datacomm %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", 0:3))) %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR", "PCRpos",
                                   "HAI_D0", "HAI_D28", "HAI_D180", "seroconversion"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::group_by(seroconversion, Timepoint, cytokine) %>%
  dplyr::summarise(
    n = dplyr::n(),
    mean = mean(log2foldchange, na.rm = T),
    sd = sd(log2foldchange, na.rm = T),
    L95 = mean - 1.96*(sd/sqrt(n)),
    U95 = mean + 1.96*(sd/sqrt(n))) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = mean, group = seroconversion, linetype = seroconversion, color = seroconversion)) +
  geom_pointrange(aes(x = Timepoint, xmin = Timepoint, xmax = Timepoint,
                      y = mean, ymin = L95, ymax = U95,
                      color = seroconversion), alpha = 0.6) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  scale_color_discrete(palette = c("#C48156", "#3EB952")) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p5

#.....................
# Complot
#...................
cowplot::plot_grid(p2,p4,nrow=1)
cowplot::plot_grid(p3,p5,nrow=1)
cowplot::plot_grid(p4,p5,nrow=1)

#++++++++++++++++++++++++++++++++++++++++++
### Section 3: ***    ####
#++++++++++++++++++++++++++++++++++++++++++



