/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>ERROR</severity>
  <title>Duplicate EOCs within WP or PP</title>
  <summary>Is the same EOC represented more than once within this WP or PP by period date?</summary>
  <message>WP or PP found with duplicate EOCs by period date.</message>
  <grouping>WBS_ID_WP,EOC,period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030054</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreEOCsDuplicatedWithinWPOrPP] (
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
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		AND WBS_ID_WP IN (
			SELECT WBS_ID_WP 
			FROM DS03_cost 
			WHERE 
				upload_ID = @upload_ID 
			AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
			GROUP BY WBS_ID_WP, EOC, period_date
			HAVING COUNT(EOC) > 1
		)
)