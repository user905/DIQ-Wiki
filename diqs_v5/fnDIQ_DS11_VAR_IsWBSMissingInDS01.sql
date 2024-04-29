/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS ID Missing In WBS Hierarchy</title>
  <summary>Is the WBS ID for this VAR missing in the WBS Hierarchy?</summary>
  <message>WBS_ID not in DS01.WBS_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110494</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsWBSMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND WBS_ID NOT IN (
			SELECT WBS_ID
			FROM DS03_cost
			WHERE upload_ID = @upload_ID
		)
)