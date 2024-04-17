/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>FC Resource Missing Among BL Resoures</title>
  <summary>Is this FC resource missing among the BL resources?</summary>
  <message>Combo of task_ID, resource_ID, role_ID, &amp; EOC (where schedule_type = BL) not found in DS06 (where schedule_type = BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060261</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsFCResourceMissingInBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BLRes as (
		SELECT task_ID, TRIM(ISNULL(resource_ID,'')) ResID, TRIM(ISNULL(role_ID,'')) RoleID, EOC
		FROM DS06_schedule_resources
		WHERE upload_id = @upload_ID AND schedule_type = 'BL'
	)
	SELECT
		FCR.*
	FROM
		DS06_schedule_resources FCR LEFT OUTER JOIN BLRes ON FCR.task_ID = BLRes.task_ID 
														 AND TRIM(ISNULL(FCR.resource_ID,'')) = BLRes.ResID 
														 AND TRIM(ISNULL(FCR.role_ID,'')) = BLRes.RoleID
														 AND FCR.EOC = BLRes.EOC
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC'
		AND BLRes.task_ID IS NULL
)