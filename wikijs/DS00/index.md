> Please note: This database of DIQs is up to date as of JSON DID v4-0-0. Some changes have been made to support Indirect scenarios as added in JSON DID v5-0-0 and later. An update is in progress to bring this documentation up to the latest standard.
{.is-warning}


## [CRITICAL](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1000001](/DIQs/DS00/1000001) | CPP Status Date Missing From Cost Periods | Is the CPP Status Date missing from the period dates in the cost file? | DS00.CPP_Status_Date not in DS03.period_date list. |
## [MAJOR](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1000002](/DIQs/DS00/1000002) | CPP Status Date Is After CD-4 | Is the CPP Status Date after CD-4? | DS00.CPP_Status_Date > min DS04.ES_date or EF_date where milestone_level = 190. |
