/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PM EAC Likely Date Prior to End of PMB Milestone</title>
  <summary>Is the PM EAC Likely date earlier than the End of PMB milestone?</summary>
  <message>EAC_PM_Likely &lt; minimum DS04.EF_date where milestone_level = 170 (BL or FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070306</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMLikelyLtEndOfPMB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with EndOfPMB as (
		SELECT MIN(EF_date) MinEF
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND milestone_level = 175
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_Likely_date < (SELECT TOP 1 MinEF FROM EndOfPMB)
)