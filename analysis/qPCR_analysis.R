## .................................................................................
## Purpose: Analyze and graph Viral Load
##
## Author: Nick Brazeau
##
## Notes:
## .................................................................................
library(tidyverse)
library(readxl)
source("R/themes.R")

#++++++++++++++++++++++++++++++++++++++++++
### Section 0: Read Data   ####
#++++++++++++++++++++++++++++++++++++++++++
qPCR_derived <- readRDS("data/derived/qPCRdata/qPCR_derived.RDS") %>%
  dplyr::rename(PID = Subject_ID) %>%
  dplyr::select(c("PID", "Woods_qPCR", "NHS_qPCR", dplyr::everything())) %>%
  tidyr::pivot_longer(data = ., cols = dplyr::starts_with("D"),
                      names_to = "Timepoint",
                      values_to = "qPCR_Ct") %>%
  dplyr::mutate(PCRpos = ifelse(NHS_qPCR == T | Woods_qPCR == T, T, F)) %>%
  dplyr::mutate(Timepoint = stringr::str_replace(Timepoint, "D-1", "Day -1")) %>%
  dplyr::mutate(Timepoint = stringr::str_replace(Timepoint, "\\bD(?=\\d)", "Day ")) %>%
  dplyr::mutate(Timepoint = factor(Timepoint, levels = paste0("Day ", -1:14)))

# HAI
hai_derived <- readRDS("data/derived/HAI_results/HAI_seroconversion.RDS")
# combined
datacomm <- dplyr::left_join(qPCR_derived, hai_derived, by = "PID")


#++++++++++++++++++++++++++++++++++++++++++
### Section 1: VL    ####
#++++++++++++++++++++++++++++++++++++++++++
p1 <- qPCR_derived %>%
  ggplot() +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = Woods_qPCR)) +
  geom_line(aes(x = Timepoint, y = qPCR_Ct, group = PID, color = Woods_qPCR, linetype = Woods_qPCR)) +
  scale_color_discrete(palette = c("#B80303", "#163B92")) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))


#..................
# Aggregate
#..................
p2 <- qPCR_derived %>%
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
  scale_color_discrete(palette = c("#B80303", "#163B92")) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

# woods obvi bc other are zeroes
p3 <- qPCR_derived %>%
  dplyr::group_by(Woods_qPCR, Timepoint) %>%
  dplyr::summarise(
    n = dplyr::n(),
    mean = mean(qPCR_Ct),
    sd = sd(qPCR_Ct),
    L95 = mean - 1.96*(sd/sqrt(n)),
    U95 = mean + 1.96*(sd/sqrt(n))) %>%
  ggplot() +
  geom_line(aes(x = Timepoint, y = mean, group = Woods_qPCR, linetype = Woods_qPCR, color = Woods_qPCR)) +
  geom_pointrange(aes(x = Timepoint, xmin = Timepoint, xmax = Timepoint,
                      y = mean, ymin = L95, ymax = U95,
                      color = Woods_qPCR)) +
  scale_color_discrete(palette = c("#B80303", "#163B92")) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))


#..................
# Complot
#..................
cowplot::plot_grid(p1,p3, nrow = 1)



#++++++++++++++++++++++++++++++++++++++++++
### Section 2: VL vs HAI   ####
#++++++++++++++++++++++++++++++++++++++++++
p3 <- datacomm %>%
  ggplot() +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = seroconversion)) +
  geom_line(aes(x = Timepoint, y = qPCR_Ct, group = PID, color = seroconversion, linetype = seroconversion)) +
  scale_color_discrete(palette = c("#B80303", "#163B92")) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p3

# just seroconv
p3_sero <- datacomm %>%
  dplyr::filter(seroconversion == T) %>%
  ggplot() +
  geom_point(aes(x = Timepoint, y = qPCR_Ct,  group = PID, color = PID), alpha = 0.5) +
  geom_line(aes(x = Timepoint, y = qPCR_Ct, group = PID, color = PID), alpha = 0.5) +
  plot_theme +
  theme(legend.position = "bottom",
        axis.text.x = element_text(family = "Helvetica", hjust = 1, size = 8, angle = 45))

p3_sero

