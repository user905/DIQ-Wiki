## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1140543](/DIQs/DS14/1140543) | Duplicate HDV-CI ID | Is the HDV-CI duplicated? | Count of HDV_CI_ID > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1140540](/DIQs/DS14/1140540) | Equipment ID Without SubK ID | Is there an equipment ID without a subcontract ID? | equipment_ID found while subK_ID is missing or blank. |
| [1140547](/DIQs/DS14/1140547) | Subcontract PO ID Missing Subcontract ID | Is there a subcontract PO ID without a subcontract ID? | subK_PO_ID found but subK_ID is missing or blank. |
| [9140539](/DIQs/DS14/9140539) | Subcontract PO & Subcontract ID Combo Misaligned with Subcontract Work Data | Is this combo subcontract PO & subcontract ID misaligned with what is in the subcontract data? | Combo of subK_PO_ID & subK_ID <> combo of DS13.subK_PO_ID & DS13.subK_ID. |
| [9140541](/DIQs/DS14/9140541) | Equipment Without Subcontract or Material Resources (BL) | Is the equipment for this HDV-CI missing accompanying baseline subcontract or material resources? | equipment_ID found where subK_ID not in DS13.subK_ID list with DS06 BL resources of EOC = material or subcontract (by DS14.subK_ID & DS13.subK_ID, and DS13.task_ID & DS06.task_ID). |
| [9140542](/DIQs/DS14/9140542) | Equipment Without Subcontract or Material Resources (FC) | Is the equipment for this HDV-CI missing accompanying forecast subcontract or material resources? | equipment_ID found where subK_ID not in DS13.subK_ID list with DS06 FC resources of EOC = material or subcontract (by DS14.subK_ID & DS13.subK_ID, and DS13.task_ID & DS06.task_ID). |
| [9140544](/DIQs/DS14/9140544) | HDV-CI Missing in Schedule (FC) | Is the HDV-CI missing in the forecast schedule? | HDV_CI_ID not in DS04.HDV_CI_ID list where schedule_type = FC. |
| [9140545](/DIQs/DS14/9140545) | HDV-CI Missing in Schedule (FC) | Is the HDV-CI missing in the forecast schedule? | HDV_CI_ID not in DS04.HDV_CI_ID list where schedule_type = FC. |
| [9140546](/DIQs/DS14/9140546) | Subcontract ID Missing in Subcontract Work Records | Is the subcontract ID missing in the subcontract dataset? | subK_ID not in DS14.subK_ID list. |
