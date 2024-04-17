/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Duplicate Resource Name</title>
  <summary>Is this resource name duplicated across resources?</summary>
  <message>Resource_name repeats across distinct resource_ids.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060247</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceNameDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Flags as (
	SELECT BLName1.resource_ID, BLName1.resource_name, BLName1.schedule_type
	FROM 
		(SELECT resource_ID, resource_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'BL' GROUP BY schedule_type, resource_ID, resource_name) BLName1,
		(SELECT resource_ID, resource_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'BL' GROUP BY schedule_type, resource_ID, resource_name) BLName2
	WHERE
			BLName1.resource_name = BLName2.resource_name
		AND BLName1.resource_ID <> BLName2.resource_ID
	UNION
	SELECT FCName1.resource_ID, FCName1.resource_name, FCName1.schedule_type
	FROM 
		(SELECT resource_ID, resource_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'FC' GROUP BY schedule_type, resource_ID, resource_name) FCName1,
		(SELECT resource_ID, resource_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'FC' GROUP BY schedule_type, resource_ID, resource_name) FCName2
	WHERE
			FCName1.resource_name = FCName2.resource_name
		AND FCName1.resource_ID <> FCName2.resource_ID
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R 		
					INNER JOIN Flags F 	ON R.schedule_type = F.schedule_type
										AND R.resource_ID = F.resource_ID
										AND R.resource_name = F.resource_name
	WHERE
			upload_id = @upload_ID
)