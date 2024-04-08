## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1210602](/DIQs/DS21/1210602) | Duplicate Rate | Is this rate duplicated by resource ID? | Count resource_ID > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1210600](/DIQs/DS21/1210600) | Indirect Rate Missing Burden | Is there a burden ID missing for this indirect rate? | type = I & burden_ID is missing or blank. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1210599](/DIQs/DS21/1210599) | Negative Or Zero Rate Dollars | Is the rate negative or zero? | rate_dollars <= 0. |
| [1210601](/DIQs/DS21/1210601) | Direct Overhead EOC | Is this Overhead rate typed as direct? | type = D & EOC = Overhead. |
| [9210602](/DIQs/DS21/9210602) | Resource & EOC Combo Missing in Forecast Resources | Is this resource EOC missing in the forecast resources? | resource_ID & EOC combo not found in DS06.resource_ID & DS06.EOC (where schedule_type = FC). |
| [9210603](/DIQs/DS21/9210603) | Labor Rate Escalation Exceeds Allowable Rate in the IPMR Header | Did the rate change for this labor resource between last FY and this FY exceed the allowed rate as provided in the IPMR header? | |(DS21.rate_dollars for current FY - DS21.rate_dollars previous FY) / DS21.rate_dollars previous FY| - DS07.escalation_rate_pct > .02 (by resource_ID). |
