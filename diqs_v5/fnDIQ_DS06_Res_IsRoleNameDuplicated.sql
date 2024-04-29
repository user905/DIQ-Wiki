/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Duplicate Role Name</title>
  <summary>Is this role name duplicated across roles?</summary>
  <message>Resource_name repeats across distinct resource_ids.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060252</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsRoleNameDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Flags as (
		SELECT BLName1.role_id, BLName1.role_name, BLName1.schedule_type
		FROM 
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'BL' GROUP BY schedule_type, role_id, role_name) BLName1,
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'BL' GROUP BY schedule_type, role_id, role_name) BLName2
		WHERE
				BLName1.role_name = BLName2.role_name
			AND BLName1.role_id <> BLName2.role_id
		UNION
		SELECT FCName1.role_id, FCName1.role_name, FCName1.schedule_type
		FROM 
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'FC' GROUP BY schedule_type, role_id, role_name) FCName1,
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'FC' GROUP BY schedule_type, role_id, role_name) FCName2
		WHERE
				FCName1.role_name = FCName2.role_name
			AND FCName1.role_id <> FCName2.role_id
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R 
					INNER JOIN Flags F 	ON R.schedule_type = F.schedule_type
										AND R.role_id = F.role_id
										AND R.role_name = F.role_name
	WHERE
			upload_id = @upload_ID
)