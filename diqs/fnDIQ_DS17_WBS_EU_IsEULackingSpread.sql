/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Lacking Spread</title>
  <summary>Are the EU minimum, likely, and maximum dollars all equal?</summary>
  <message>EU_min_dollars = EU_likely_dollars = EU_max_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1170574</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsEULackingSpread] (
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
		AND EU_min_dollars = EU_likely_dollars
		AND EU_likely_dollars = EU_max_dollars
)