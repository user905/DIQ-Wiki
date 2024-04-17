/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Apportioned To WBS ID Missing</title>
  <summary>Is the WBS ID to which this work is apportioned missing?</summary>
  <message>EVT = J or M but EVT_J_to_WBS_ID is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030077</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsApportionedToIDMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND	EVT IN ('J','M')
		AND TRIM(ISNULL(EVT_J_to_WBS_ID,''))=''
)