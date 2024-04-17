/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>ERROR</severity>
  <title>Duplicate EOCs within CA</title>
  <summary>Is the same EOC represented more than once within a CA by period date?</summary>
  <message>CA found with duplicate EOCs by period date.</message>
  <grouping>WBS_ID_CA,EOC,period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030053</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreEOCsDuplicatedWithinCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		C.* 
	FROM 
		DS03_Cost C
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		AND WBS_ID_CA IN (
			SELECT WBS_ID_CA 
			FROM DS03_cost 
			WHERE 
				upload_ID = @upload_ID 
			AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
			GROUP BY WBS_ID_CA, EOC, period_date
			HAVING COUNT(EOC) > 1
		)
)