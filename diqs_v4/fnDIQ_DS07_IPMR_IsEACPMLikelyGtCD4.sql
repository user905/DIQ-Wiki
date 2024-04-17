/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM EAC Likely Date After CD-4</title>
  <summary>Is the PM EAC Likely date later than the CD-4 milestone?</summary>
  <message>EAC_PM_Likely_date &gt; minimum DS04.EF_date where milestone_level = 190 (FC only).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070308</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMLikelyGtCD4] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CD4 as (
		SELECT MIN(EF_date) MinEF
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND milestone_level = 190 AND schedule_type = 'FC'
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_likely_date > (SELECT TOP 1 MinEF FROM CD4)
)