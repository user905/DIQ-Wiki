/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Equipment Without Subcontract or Material Resources (FC)</title>
  <summary>Is the equipment for this HDV-CI missing accompanying forecast subcontract or material resources?</summary>
  <message>equipment_ID found where subK_ID not in DS13.subK_ID list with DS06 FC resources of EOC = material or subcontract (by DS14.subK_ID &amp; DS13.subK_ID, and DS13.task_ID &amp; DS06.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9140542</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_IsEquipMissingDS06SubKOrMatEOCFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SubKResources as (
		SELECT S.subK_ID
		FROM DS13_subK S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_ID AND R.upload_ID = @upload_ID 
		AND R.schedule_type = 'FC' AND R.EOC IN ('Material','Subcontract')
		GROUP BY S.subK_ID
	)
	SELECT 
		*
	FROM
		DS14_HDV_CI H
	WHERE
			upload_ID = @upload_ID
		AND TRIM(equipment_ID) <> ''
		AND subK_ID NOT IN (SELECT subK_ID FROM SubKResources)
)