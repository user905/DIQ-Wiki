/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Duplicate Resource</title>
  <summary>Is this resource duplicated across subprojects?</summary>
  <message>Count of Resource_id &gt; 1 across distinct subproject_id.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060266</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT R1.*
	FROM DS06_schedule_resources R1 INNER JOIN  DS06_schedule_resources R2 ON R1.resource_id = R2.resource_id
                                                                        AND R1.schedule_type = R2.schedule_type
                                                                        AND ISNULL(R1.subproject_id,'') <> ISNULL(R2.subproject_id,'')
	WHERE R1.upload_id = @upload_ID AND R2.upload_ID = @upload_id
)