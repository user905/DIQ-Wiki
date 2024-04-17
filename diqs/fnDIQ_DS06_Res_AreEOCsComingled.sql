/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EOCs Improperly Mingled</title>
  <summary>Are material, ODC, subcontract, or labor EOCs comingled in the same task?</summary>
  <message>Task_ID found with combo of material, ODC, subcontract, and/or labor EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060264</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreEOCsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		R1.*
	FROM
		DS06_schedule_resources R1 INNER JOIN DS06_schedule_resources R2 ON R1.task_ID = R2.task_ID
																		AND R1.schedule_type = R2.schedule_type
																		AND ISNULL(R1.subproject_ID,'') = ISNULL(R2.subproject_ID,'')
																		AND ISNULL(R1.EOC,'') <> ISNULL(R2.EOC,'')
	WHERE
			R1.upload_id = @upload_ID
		AND R2.upload_id = @upload_ID
		AND R1.EOC <> 'Indirect'
		AND R2.EOC <> 'Indirect'
)