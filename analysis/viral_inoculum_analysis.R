## .................................................................................
## Purpose: Analyze Viral Inoculum Data
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
# viral inoculum
vi <- readr::read_tsv("data/raw/viral_inoculum/SubjectCohortwViralDose_08Oct2018.txt")
colnames(vi) <- c("PID", "cohort", "viral_dose")

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
# symtpoms
sx <- readxl::read_excel("data/raw/clinical_data/response_summary.xlsx") %>%
  dplyr::select(c("subjectID", "symptom_response", "total_sx_score")) %>%
  dplyr::rename(PID = subjectID)


#.....................
# Combine
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
  dplyr::left_join(., vi, by = "PID") %>%
  dplyr::left_join(., hai_derived, by = "PID") %>%
  dplyr::left_join(., sx, by = "PID")



### EDA
datacomm %>%
  dplyr::select(c("PID", "seroconversion", "viral_dose", "PCRpos", "Woods_qPCR", "symptom_response")) %>%
  dplyr::filter(!duplicated(.)) %>%
  dplyr::arrange(viral_dose)

  xtabs(PCRpos ~ viral_dose + seroconversion, data = .)


datacomm %>%
  dplyr::select(c("PID", "seroconversion", "viral_dose", "Woods_qPCR")) %>%
  dplyr::filter(!duplicated(.)) %>%
  xtabs(Woods_qPCR ~ viral_dose + seroconversion, data = .)


LITERALLY HAVE COMPARTMENT BASED DATA


eda <- datacomm %>%
  dplyr::select(c("PID", "seroconversion", "viral_dose", "PCRpos", "Woods_qPCR", "symptom_response", "total_sx_score")) %>%
  dplyr::filter(!duplicated(.)) %>%
  mutate(
    log_dose = log10(viral_dose),
    sym      = factor(symptom_response, levels = c(0,1), labels = c("Sx−", "Sx+")),
    pcr      = factor(PCRpos, levels = c(FALSE, TRUE), labels =  c("PCR−", "PCR+")),
    woodspcr = factor(Woods_qPCR, levels = c(FALSE, TRUE), labels = c("PCR−", "PCR+"))
  )

eda %>%
  count(pcr, sym, seroconversion) %>%
  pivot_wider(names_from = seroconversion, values_from = n,
              values_fill = 0, names_prefix = "sero_")

eda %>%
  count(woodspcr, sym, seroconversion) %>%
  pivot_wider(names_from = seroconversion, values_from = n,
              values_fill = 0, names_prefix = "sero_")



eda %>%
  count(log_dose, pcr, sym, seroconversion) %>%
  pivot_wider(names_from = seroconversion, values_from = n,
              values_fill = 0, names_prefix = "sero_")


eda %>%
  ggplot() +
  geom_point(aes(x = log_dose, y = pcr, color = seroconversion),
             size = 5, alpha = 0.5,
             position = position_jitter(0, 0.15, seed = 1)) +
  ggrepel::geom_text_repel(aes(x = log_dose, y = pcr, label = PID), size = 3, max.overlaps = 20) +
  scale_color_manual(values = c(`FALSE` = "grey85", `TRUE` = "#B2182B"),
                    name = "Seroconverted") +
  labs(x = expression(log[10]~"challenge dose (TCID"[50]*")"), y = NULL) +
  plot_theme

summ <- eda %>%
  count(pcr, sym, seroconversion) %>%
  pivot_wider(names_from = seroconversion, values_from = n,
              values_fill = 0, names_prefix = "sero_")



pB <- ggplot(summ, aes(x = sym, y = p, colour = pcr, group = pcr)) +
  geom_line(position = position_dodge(0.25)) +
  geom_pointrange(aes(ymin = lo, ymax = hi), position = position_dodge(0.25)) +
  geom_text(aes(label = paste0(kTRUE, "/", n)), vjust = -1.2, size = 3,
            position = position_dodge(0.25), show.legend = FALSE) +
  scale_y_continuous(limits = c(0, 1.05)) +
  labs(x = NULL, y = "P(seroconversion)", colour = NULL,
       title = "B. Empirical risk, 95% Wilson CI") +
  theme_bw(base_size = 11)

cowplot::plot_grid(pA, pB, widths = c(1.6, 1))


