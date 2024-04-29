/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WBS Time Dependence Inconsistent</title>
  <summary>Is the time dependent flag inconsistent within this WBS?</summary>
  <message>time_dependent is not all Y or all N by WBS_ID.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1170580</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsTimeDepInconsistent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS17_WBS_EU
	WHERE 
			upload_ID = @upload_ID
		AND WBS_ID IN (
			SELECT WBS_ID
			FROM DS17_WBS_EU
			WHERE upload_ID = @upload_ID
			GROUP BY WBS_ID
			HAVING MIN(time_dependent) <> MAX(time_dependent)
		)
)