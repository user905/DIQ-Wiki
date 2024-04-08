## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1090440](/DIQs/DS09/1090440) | Duplicate CC Log Entry | Is this CC Log entry duplicated by CC Log ID & Supplement ID? | Count of CC_log_ID & CC_log_ID_supplement combo > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1090439](/DIQs/DS09/1090439) | Approved Date After Implementation Date | Is the approved date later than the implementation date? | approved_date > implementation_date. |
| [1090441](/DIQs/DS09/1090441) | Original UB CC Log ID Missing in CC Log ID List | Is this Original UB CC Log ID missing in the CC Log ID list? | CC_log_ID_original_UB missing in CC_log_ID list. |
| [1090447](/DIQs/DS09/1090447) | Missing PM | Is the PM name missing on this CC log entry? | PM null or blank. |
| [9090442](/DIQs/DS09/9090442) | CC Log ID Missing in CC Log Detail | Is this CC Log ID missing in the log detail? | CC_log_ID missing in DS10.CC_log_ID list. |
| [9090443](/DIQs/DS09/9090443) | Log Dollars Delta Misaligned With Log Detail Delta | Is the dollars delta for this CC Log entry misaligned with what is in the CC Log detail table? | dollars_delta <> SUM(DS10.dollars_delta) (by CC_log_ID). |
| [9090444](/DIQs/DS09/9090444) | Log Hours Delta Misaligned With Log Detail Delta | Is the hours delta for this CC Log entry misaligned with what is in the CC Log detail table? | hours_delta <> SUM(DS10.hours_delta) (by CC_log_ID). |
| [9090446](/DIQs/DS09/9090446) | PM Misaligned with WADs | Is the PM name misaligned with what is in the WADs? | PM <> DS08.PM where approved_date > CPP_SD_Date - 1. |
| [9090449](/DIQs/DS09/9090449) | BCP Change Control Without BCP | Does this BCP change control log entry exist without a BCP in the schedule? | type = BCP & count = 0 where DS04.milestone_level between 131 & 135. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1090449](/DIQs/DS09/1090449) | Risk Missing | Are risk IDs missing in the CC log? | Count of CC log entries > 5 & Count of risk_id = 0. |
| [9090445](/DIQs/DS09/9090445) | Implementation Date Missing or Unreasonable | Is the implementation date missing or is it considerably after the approved date? | implementation_date is missing or > the next DS03.period_date after the current DS09.approved_date. |
| [9090448](/DIQs/DS09/9090448) | Risk Missing in Risk Register | Is this risk ID missing in the risk register? | risk_id missing in DS15.risk_ID list. |
