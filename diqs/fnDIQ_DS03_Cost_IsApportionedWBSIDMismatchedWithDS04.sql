/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Apportionment IDs Mismatch Between Cost and Schedule</title>
  <summary>Is the WBS ID to which this work is apportioned mismatched in cost and schedule?</summary>
  <message>EVT = J or M where EVT_J_to_WBS_ID does not equal the WBS ID in Schedule.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030078</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsApportionedWBSIDMismatchedWithDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ScheduleApportioned AS (
		SELECT S1.WBS_ID WBSID, S2.WBS_ID ApportionedToWBSId
		FROM DS04_schedule S1 INNER JOIN DS04_schedule S2 ON S1.EVT_J_to_task_ID = S2.task_ID
		WHERE 
			S1.upload_ID = @upload_ID 
		AND S2.upload_ID = @upload_ID
		AND S1.schedule_type = 'FC'
		AND S2.schedule_type = 'FC'
		AND S1.EVT_J_to_task_ID IS NOT NULL
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN ScheduleApportioned S ON C.WBS_ID_WP = S.WBSID
	WHERE
			upload_ID = @upload_ID
		AND	EVT IN ('J','M')
		AND C.EVT_J_to_WBS_ID IS NOT NULL
		AND (
				TRIM(ISNULL(C.EVT_J_to_WBS_ID,'')) <> TRIM(ISNULL(S.ApportionedToWBSId,''))
			OR S.ApportionedToWBSId IS NULL -- If the WBS ID is NULL, then the task is not apportioned to anything.
		)
)