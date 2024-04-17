/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Labor Dollars without Labor Hours</title>
  <summary>Does this WAD have labor dollars but not labor hours?</summary>
  <message>budget_labor_dollars &gt; 0 &amp; budget_labor_hours = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080402</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_DoLaborDollarsExistWithoutLaborHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID  
		AND budget_labor_dollars > 0 
		AND ISNULL(budget_labor_hours,0) = 0
)