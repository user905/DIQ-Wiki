## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1190593](/DIQs/DS19/1190593) | Duplicate Calendar Name | Is this calendar name duplicated in the dataset? | Count calendar_name > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1190592](/DIQs/DS19/1190592) | Hours Per Day Less Than Zero Or Greater Than 24 | Are the hours per day negative or greater than 24? | hours_per_day < 0 or hours_per_day > 24. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1190594](/DIQs/DS19/1190594) | Shift Exceeds 12 Hours | Are the hours of any of your shifts in excess of 12 hours? | Hours delta between std_##_DDD_shift_#_start_time & std_##_DDD_shift_#_stop_time > 12. |
