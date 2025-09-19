
library("dplyr")

form_5500 <- read.csv("./inst/extdata/f_5500_2023_latest.csv",
                      header = TRUE,
                      sep = ",",
                      na.strings = c(""),
                      stringsAsFactors = FALSE)

plans <- form_5500 %>%
  select(ACK_ID,
         FORM_PLAN_YEAR_BEGIN_DATE,
         FORM_TAX_PRD,
         TYPE_PLAN_ENTITY_CD,
         FINAL_FILING_IND,
         PLAN_NAME,
         SPONS_DFE_PN,
         PLAN_EFF_DATE,
         SPONSOR_DFE_NAME,
         SPONS_DFE_MAIL_US_STATE,
         SPONS_DFE_EIN,
         BUSINESS_CODE,
         TOT_PARTCP_BOY_CNT,
         TOT_ACTIVE_PARTCP_CNT,
         PARTCP_ACCOUNT_BAL_CNT,
         SEP_PARTCP_PARTL_VSTD_CNT,
         TYPE_PENSION_BNFT_CODE,
         TOT_ACT_PARTCP_BOY_CNT,
         PARTCP_ACCOUNT_BAL_CNT_BOY) %>%
  filter(FORM_PLAN_YEAR_BEGIN_DATE == "2023-01-01" & 
           FORM_TAX_PRD == "2023-12-31" & 
           FINAL_FILING_IND != 1 &
           TYPE_PLAN_ENTITY_CD == 2 &
           stringr::str_detect(TYPE_PENSION_BNFT_CODE, "2K|2S|2R|2T"))

schedule_h <- read.csv("./inst/extdata/f_sch_h_2023_latest.csv",
                       header = TRUE,
                       sep = ",",
                       na.strings = c(""),
                       stringsAsFactors = FALSE)

schedule_h <- schedule_h %>%
  select(ACK_ID,
         EMPLR_CONTRIB_BOY_AMT,
         EMPLR_CONTRIB_EOY_AMT,
         PARTCP_CONTRIB_BOY_AMT,
         PARTCP_CONTRIB_EOY_AMT,
         PARTCP_LOANS_BOY_AMT,
         PARTCP_LOANS_EOY_AMT,
         PARTICIPANT_CONTRIB_AMT,
         DISTRIB_DRT_PARTCP_AMT,
         TOT_DISTRIB_BNFT_AMT,
         TOT_TRANSFERS_TO_AMT,
         TOT_TRANSFERS_FROM_AMT,
         TOT_ASSETS_BOY_AMT,
         TOT_ASSETS_EOY_AMT)

plans <- left_join(plans, schedule_h, by = "ACK_ID") %>% tidyr::drop_na()

saveRDS(plans, "./data/plans.rds")

write.csv(plans, "./data/plans.csv")
