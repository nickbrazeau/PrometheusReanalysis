library(tidyverse)
library(readxl)
library(pheatmap)
source("R/themes.R")

#++++++++++++++++++++++++++++++++++++++++++
### Section 0: Read Data   ####
#++++++++++++++++++++++++++++++++++++++++++
cytokinedata_transformed <- readRDS("data/derived/cytokines/cytokinedata_log2transformed.RDS")
qPCR_derived <- readRDS("data/derived/qPCRdata/qPCR_derived.RDS") %>%
  dplyr::rename(PID = Subject_ID) %>%
  dplyr::select(c("PID", "Woods_qPCR", "NHS_qPCR", dplyr::everything())) %>%
  tidyr::pivot_longer(data = ., cols = dplyr::starts_with("D"),
                      names_to = "Timepoint",
                      values_to = "qPCR_Ct") %>%
  dplyr::mutate(Timepoint = stringr::str_replace(Timepoint, "\\bD(?=\\d)", "Day "))


#.....................
# Combined
#...................
qPCR_derived_PCR <- qPCR_derived %>%
  dplyr::select(-c("Woods_qPCR", "NHS_qPCR"))

qPCR_derived_ret <- qPCR_derived %>%
  dplyr::select(c("PID", "Woods_qPCR", "NHS_qPCR")) %>%
  dplyr::filter(!duplicated(PID))

datacomm <- dplyr::full_join(cytokinedata_transformed, qPCR_derived_PCR,
                             by = c("PID", "Timepoint")) %>%
  dplyr::left_join(., qPCR_derived_ret, by = "PID", relationship = "many-to-many")

#++++++++++++++++++++++++++++++++++++++++++
### Section 1: VL    ####
#++++++++++++++++++++++++++++++++++++++++++
qPCR_derived %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", 0:14))) %>%
  ggplot() +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = Woods_qPCR, shape = NHS_qPCR)) +
  geom_line(aes(x = Timepoint, y = qPCR_Ct, group = PID, color = Woods_qPCR, linetype = NHS_qPCR)) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

qPCR_derived %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", 0:14))) %>%
  ggplot() +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = NHS_qPCR, shape = Woods_qPCR)) +
  geom_line(aes(x = Timepoint, y = qPCR_Ct, group = PID, color = NHS_qPCR, linetype = Woods_qPCR)) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))


qPCR_derived %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", 0:14))) %>%
  dplyr::mutate(PCRpos = ifelse(NHS_qPCR == T | Woods_qPCR == T, T, F)) %>%
  dplyr::group_by(PCRpos, Timepoint) %>%
  dplyr::summarise(
    n = dplyr::n(),
    mean = mean(qPCR_Ct),
    sd = sd(qPCR_Ct),
    L95 = mean - 1.96*(sd/sqrt(n)),
    U95 = mean + 1.96*(sd/sqrt(n))) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = mean, group = PCRpos, linetype = PCRpos, color = PCRpos)) +
  geom_pointrange(aes(x = Timepoint, xmin = Timepoint, xmax = Timepoint,
                      y = mean, ymin = L95, ymax = U95,
                      color = PCRpos)) +
plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))





#++++++++++++++++++++++++++++++++++++++++++
### Section 2: Cytokines    ####
#++++++++++++++++++++++++++++++++++++++++++
cytokinedata_transformed %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))


cytokinedata_transformed %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(cytokine %in% c("IFN-γ")) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))


datacomm %>%
  dplyr::filter(Woods_qPCR == FALSE & NHS_qPCR == TRUE) %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))






#++++++++++++++++++++++++++++++++++++++++++
### Section 3: Cytokines and VL   ####
#++++++++++++++++++++++++++++++++++++++++++
datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(cytokine %in% c("IFN-γ")) %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID, linetype = NHS_qPCR)) +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = PID, shape = NHS_qPCR)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

# longer day

datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", 0:14))) %>%
  dplyr::filter(cytokine %in% c("IFN-γ")) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PID, linetype = NHS_qPCR)) +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = PID, shape = NHS_qPCR)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

# infnx
datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::mutate(PCRpos = ifelse(NHS_qPCR == T | Woods_qPCR == T, T, F)) %>%
  dplyr::filter(cytokine %in% c("IFN-γ", "IP-10", "IL-6", "IL-10", "TNF-α")) %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PCRpos, linetype = PCRpos)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))




# MESS AROUND
datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(PID %in% c("PROM001", "PROM031", "PROM032", "PROM033", "PROM034")) %>%
  dplyr::mutate(PCRpos = ifelse(NHS_qPCR == T | Woods_qPCR == T, T, F)) %>%
  dplyr::filter(cytokine %in% c("IFN-γ", "IL-6", "IL-1β", "IP-10")) %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = PCRpos, linetype = PCRpos)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))




# MESS AROUND
datacomm %>%
  tidyr::pivot_longer(., cols = -c("PID", "Timepoint", "qPCR_Ct", "Woods_qPCR", "NHS_qPCR"),
                      names_to = "cytokine", values_to = "log2foldchange") %>%
  dplyr::filter(PID %in% c("PROM001", "PROM031", "PROM032", "PROM033", "PROM034")) %>%
  dplyr::mutate(PCRpos = ifelse(NHS_qPCR == T | Woods_qPCR == T, T, F)) %>%
  dplyr::filter(cytokine %in% c("IFN-γ", "IL-6", "IL-1β", "IP-10")) %>%
  dplyr::filter(!is.na(log2foldchange)) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = log2foldchange, group = PID, color = Woods_qPCR, linetype = Woods_qPCR)) +
  facet_wrap(~cytokine, scales = "free") +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))







