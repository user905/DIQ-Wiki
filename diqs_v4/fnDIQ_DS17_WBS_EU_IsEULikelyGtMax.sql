/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Likely Dollars Greater Than Max</title>
  <summary>Are the EU likely dollars greater than the max dollars?</summary>
  <message>EU_likely_dollars &gt; EU_max_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1170575</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsEULikelyGtMax] (
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
		AND EU_likely_dollars > EU_max_dollars
)