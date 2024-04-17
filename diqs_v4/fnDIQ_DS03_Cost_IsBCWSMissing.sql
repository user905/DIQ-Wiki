/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Budget Missing</title>
  <summary>Is this WP or PP missing budget?</summary>
  <message>WP or PP found with BCWSi = 0 (on Dollars, or Hours / FTEs where EOC = Labor).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030081</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsBCWSMissing] (
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
		AND (
			BCWSi_dollars = 0 OR 
			(EOC = 'Labor' AND (BCWSi_FTEs = 0 OR BCWSi_hours = 0))
		)
)