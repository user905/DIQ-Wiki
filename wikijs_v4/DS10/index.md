## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1100478](/DIQs/DS10/1100478) | Duplicate CC Log Detail Transaction | Is the transaction duplicated by transaction & CC log ID? | Count of transaction_ID & CC_log_ID combo > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1100451](/DIQs/DS10/1100451) | AUW Dollar Change Exceeds NTE | Does this AUW dollar change above the NTE? | AUW = Y & dollars_delta > NTE_dollars_delta. |
| [1100452](/DIQs/DS10/1100452) | Negative AUW Dollar Delta with Non-Zero NTE | Does this negative AUW dollar change also have an NTE? | AUW = Y & dollars_delta < 0 & NTE_dollars_delta <> 0. |
| [1100458](/DIQs/DS10/1100458) | Negative NTE Delta Dollars | Is the NTE delta dollars value negative on this transaction? | NTE_dollars_delta < 0. |
| [1100461](/DIQs/DS10/1100461) | AUW Change Missing Dollars Delta | Is this change to AUW missing a dollar amount? | AUW = Y & dollars_delta = null or zero. |
| [1100464](/DIQs/DS10/1100464) | DB Transaction Missing WBS ID | Is this DB transaction missing a WBS ID? | category = DB & WBS_ID is missing or blank. |
| [1100465](/DIQs/DS10/1100465) | Description Missing | Is the description missing? | description is null or blank. |
| [1100467](/DIQs/DS10/1100467) | Hours Delta without Dollars | Are there hours on this transaction but no dollars? | hours_delta <> 0 & dollars_delta = 0. |
| [1100474](/DIQs/DS10/1100474) | POP Start After POP Finish | Is the POP start on this transaction later than the POP finish? | POP_start_date > POP_finish_date. |
| [1100479](/DIQs/DS10/1100479) | MR Entry Missing in CC Log Detail | Are there no MR entries in the CC Log detail? | Count where category = MR is 0. |
| [9100450](/DIQs/DS10/9100450) | AUW Transaction Dollars Misaligned With Project Level AUW | Are the dollars delta for AUW-related transactions misaligned with the AUW dollar value in the IPMR header? | Sum of dollars_delta where AUW = Y <> DS07.AUW_dollars. |
| [9100453](/DIQs/DS10/9100453) | DB Dollar Transactions Misaligned with Cost (CA) | Do the DB transaction dollars for this Control Account sum to something other than the DB in cost? | Sum of dollars_delta where category = DB <> Sum of DS03.BCWSi_dollars (by WBS_ID_CA). |
| [9100454](/DIQs/DS10/9100454) | DB Dollar Transactions Misaligned with Cost (WP) | Do the DB transaction dollars for this Work Package sum to something other than the DB in cost? | Sum of dollars_delta where category = DB <> Sum of DS03.BCWSi_dollars (by WBS_ID_WP). |
| [9100455](/DIQs/DS10/9100455) | DB Hour Transactions Misaligned with Cost (CA) | Do the DB transaction hours for this Control Account sum to something other than the DB in cost? | Sum of hours_delta where category = DB <> Sum of DS03.BCWSi_hours (by WBS_ID_CA). |
| [9100456](/DIQs/DS10/9100456) | DB Hour Transactions Misaligned with Cost (WP) | Do the DB transaction hours for this Work Package sum to something other than the DB in cost? | Sum of hours_delta where category = DB <> Sum of DS03.BCWSi_hours (by WBS_ID_WP). |
| [9100457](/DIQs/DS10/9100457) | MR Transaction Dollars Misaligned With Project Level MR | Are the dollars delta for MR-related transactions misaligned with the MR dollar value in the IPMR header? | Sum of dollars_delta where category = MR <> DS07.MR_dollars. |
| [9100459](/DIQs/DS10/9100459) | UB Transaction Dollars Misaligned With Project Level UB | Are the dollars delta for UB-related transactions misaligned with the UB dollar value in the IPMR header? | Sum of dollars_delta where category = UB <> DS07.UB_bgt_dollars. |
| [9100460](/DIQs/DS10/9100460) | OTB or OTS Transaction Dollars Without OTB-OTS Date | Are there OTB/OTS transactions when no OTB/OTS date exists? | Sum of dollars_delta where category = OTB, OTS, or OTB-OTS <> 0 & DS07.OTB_OTS_date is missing. |
| [9100462](/DIQs/DS10/9100462) | CC Log ID Missing in CC Log | Is the CC Log Id for this transaction missing in the CC Log table? | CC_log_ID not in DS09.CC_log_ID list. |
| [9100463](/DIQs/DS10/9100463) | DB Transaction On Non-CA, SLPP, PP, or WP | Is this DB transaction being applied to something other than a CA, SLPP, PP, or WP? | category = DB & DS01.type <> CA, SLPP, PP, or WP. |
| [9100468](/DIQs/DS10/9100468) | UB, MR, or CNT Transaction Below Project Level | Is this UB, MR, or CNT transaction being applied below the project level? | category = UB, MR, or CNT & DS01.level <> 1 (by WBS_ID). |
| [9100471](/DIQs/DS10/9100471) | POP Finish Misaligned with WAD (CA) | Is the POP finish for this Control Account misaligned with what is in the WAD? | POP_finish_date <> DS08.POP_finish_date (select latest revision; check is on CA level). |
| [9100472](/DIQs/DS10/9100472) | POP Finish Misaligned with WAD (WP) | Is the POP finish for this Work Package misaligned with what is in the WAD? | POP_finish_date <> DS08.POP_finish_date (select latest revision; check is on WP/PP level). |
| [9100473](/DIQs/DS10/9100473) | POP Finish Misaligned with WAD (CA) | Is the POP finish for this Control Account misaligned with what is in the WAD? | POP_finish_date <> DS08.POP_finish_date (select latest revision; check is on CA level). |
| [9100475](/DIQs/DS10/9100475) | POP Start Misaligned with WAD (CA) | Is the POP start for this Control Account misaligned with what is in the WAD? | POP_start_date <> DS08.POP_start_date (select latest revision; check is on CA level). |
| [9100476](/DIQs/DS10/9100476) | POP Start Misaligned with WAD (WP) | Is the POP start for this Work Package misaligned with what is in the WAD? | POP_start_date <> DS08.POP_start_date (select latest revision; check is on WP/PP level). |
| [9100477](/DIQs/DS10/9100477) | POP Start Misaligned with WAD (CA) | Is the POP start for this Control Account misaligned with what is in the WAD? | POP_start_date <> DS08.POP_start_date (select latest revision; check is on CA level). |
| [9100479](/DIQs/DS10/9100479) | WBS Missing In WBS Dictionary | Is this WBS ID missing in the WBS Dictionary? | WBS_ID missing in DS01.WBS_ID list. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1100466](/DIQs/DS10/1100466) | Dollars Delta Missing | Is the dollars delta for this transaction missing or zero? | dollars_delta missing or 0. |
| [9100469](/DIQs/DS10/9100469) | OTB/OTS Transactions Misaligned with Cost (CA) | Do the OTB/OTS transaction dollars for this Control Account sum to something other than the BAC reprogramming in cost? | Sum of dollars_delta where category = OTB, OTS, or OTB-OTS <> Sum of DS03.BAC_rpg (by WBS_ID_CA). |
| [9100470](/DIQs/DS10/9100470) | OTB/OTS Transactions Misaligned with Cost (WP) | Do the OTB/OTS transaction dollars for this Work Package sum to something other than the BAC reprogramming in cost? | Sum of dollars_delta where category = OTB, OTS, or OTB-OTS <> Sum of DS03.BAC_rpg (by WBS_ID_WP). |
