/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BL Resource Missing Among FC Resoures</title>
  <summary>Is this BL resource missing among the FC resources?</summary>
  <message>Combo of task_ID, resource_ID, role_ID, &amp; EOC (where schedule_type = BL) not found in DS06 (where schedule_type = FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060260</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsBLResourceMissingInFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with FCRes as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP, TRIM(ISNULL(resource_ID,'')) ResID, TRIM(ISNULL(role_ID,'')) RoleID, EOC
		FROM DS06_schedule_resources
		WHERE upload_id = @upload_ID AND schedule_type = 'FC'
	)
	SELECT BLR.*
	FROM DS06_schedule_resources BLR LEFT OUTER JOIN FCRes 	ON BLR.task_ID = FCRes.task_ID 
															AND ISNULL(BLR.subproject_ID,'') = FCRes.SubP
															AND TRIM(ISNULL(BLR.resource_ID,'')) = FCRes.ResID 
															AND TRIM(ISNULL(BLR.role_ID,'')) = FCRes.RoleID
															AND BLR.EOC = FCRes.EOC
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL'
		AND FCRes.task_ID IS NULL
)