/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PM EAC Likely Date After Contract Completion</title>
  <summary>Is the PM EAC Likely date later than the Contract Completion milestone?</summary>
  <message>EAC_PM_Likely_date &gt; minimum DS04.EF_date where milestone_level = 180 (FC only).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070307</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMLikelyGtContractCompletion] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ContComp as (
		SELECT MIN(EF_date) MinEF
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND milestone_level = 180 AND schedule_type = 'FC'
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_likely_date > (SELECT TOP 1 MinEF FROM ContComp)
)