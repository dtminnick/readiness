
library("dplyr")

form_5500 <- read.csv("./inst/extdata/f_5500_2023_latest.csv",
                      header = TRUE,
                      sep = ",",
                      na.strings = c(""),
                      stringsAsFactors = FALSE)

plans <- form_5500 %>%
  filter(FORM_PLAN_YEAR_BEGIN_DATE == "2023-01-01" & 
         FORM_TAX_PRD == "2023-12-31" & 
         FINAL_FILING_IND != 1 &
         TYPE_PLAN_ENTITY_CD == 2 &
         stringr::str_detect(TYPE_PENSION_BNFT_CODE, "2K|2S|2R|2T")) %>%
  select(ACK_ID,
         FORM_PLAN_YEAR_BEGIN_DATE,
         FORM_TAX_PRD,
         PLAN_NAME,
         PLAN_EFF_DATE,
         TYPE_PENSION_BNFT_CODE,
         SPONSOR_DFE_NAME,
         SPONS_DFE_MAIL_US_STATE,
         SPONS_DFE_EIN,
         BUSINESS_CODE,
         TOT_ACT_PARTCP_BOY_CNT,
         TOT_ACTIVE_PARTCP_CNT,
         PARTCP_ACCOUNT_BAL_CNT_BOY,
         PARTCP_ACCOUNT_BAL_CNT)

schedule_h <- read.csv("./inst/extdata/f_sch_h_2023_latest.csv",
                       header = TRUE,
                       sep = ",",
                       na.strings = c(""),
                       stringsAsFactors = FALSE)

schedule_h <- schedule_h %>%
  select(ACK_ID,
         PARTCP_CONTRIB_BOY_AMT,
         PARTCP_CONTRIB_EOY_AMT,
         EMPLR_CONTRIB_BOY_AMT,
         EMPLR_CONTRIB_EOY_AMT,
         PARTCP_LOANS_BOY_AMT,
         PARTCP_LOANS_EOY_AMT,
         TOT_ASSETS_BOY_AMT,
         TOT_ASSETS_EOY_AMT)

plans <- left_join(plans, schedule_h, by = "ACK_ID") %>% 
  tidyr::drop_na() %>%
  rename(PLAN_YEAR_BEGIN_DATE = FORM_PLAN_YEAR_BEGIN_DATE,
         PLAN_YEAR_END_DATE = FORM_TAX_PRD,
         PLAN_EFFECTIVE_DATE = PLAN_EFF_DATE,
         PLAN_TYPE = TYPE_PENSION_BNFT_CODE,
         SPONSOR_NAME = SPONSOR_DFE_NAME,
         SPONSOR_STATE = SPONS_DFE_MAIL_US_STATE,
         SPONSOR_EIN = SPONS_DFE_EIN,
         TOTAL_ACTIVE_PARTCP_BOY = TOT_ACT_PARTCP_BOY_CNT,
         TOTAL_ACTIVE_PARTCP_EOY = TOT_ACTIVE_PARTCP_CNT,
         TOTAL_ACCBAL_PARTCP_BOY = PARTCP_ACCOUNT_BAL_CNT_BOY,
         TOTAL_ACCBAL_PARTCP_EOY = PARTCP_ACCOUNT_BAL_CNT,
         TOTAL_CONTRIB_PARTCP_BOY = PARTCP_CONTRIB_BOY_AMT,
         TOTAL_CONTRIB_PARTCP_EOY = PARTCP_CONTRIB_EOY_AMT,
         TOTAL_CONTRIB_EMPLR_BOY = EMPLR_CONTRIB_BOY_AMT,
         TOTAL_CONTRIB_EMPLR_EOY = EMPLR_CONTRIB_EOY_AMT,
         TOTAL_LOANS_BOY = PARTCP_LOANS_BOY_AMT,
         TOTAL_LOANS_EOY = PARTCP_LOANS_EOY_AMT,
         TOTAL_ASSETS_BOY = TOT_ASSETS_BOY_AMT,
         TOTAL_ASSETS_EOY = TOT_ASSETS_EOY_AMT)

business_codes <- read.csv("./inst/extdata/industry_titles.csv",
                           header = TRUE,
                           sep = ",",
                           na.strings = c(""),
                           stringsAsFactors = FALSE)

new_rows <- data.frame(industry_code = c(221500, 524140, 524150),
                       industry_title = c("Combination gas and electric", 
                                          "Direct life health medical insurance carriers",
                                          "Direct insurance carriers agencies and brokerages"))

business_codes <- bind_rows(business_codes, new_rows)

business_codes <- business_codes %>%
  rename(BUSINESS_CODE = industry_code,
         INDUSTRY_TITLE = industry_title) %>%
  mutate(BUSINESS_CODE = as.integer(stringr::str_pad(BUSINESS_CODE,
                                          width = 6,
                                          side = "right",
                                          pad = 0)),
         INDUSTRY_TITLE = stringr::str_remove(INDUSTRY_TITLE, 
                                              "^(NAICS(07|12|17)?\\s*\\d{2,6}|\\d{2,4})\\s*"),
         INDUSTRY_TITLE = stringr::str_remove(INDUSTRY_TITLE,
                                              "^(-?\\d{1,6})\\s*")) %>%
  distinct_all()

saveRDS(business_codes, "./data/business_codes.rds")

plans <- left_join(plans, business_codes, by = "BUSINESS_CODE")

saveRDS(plans, "./data/plans.rds")

write.csv(plans, "./data/plans.csv")

write.csv(plans, "./data/plans.txt")
