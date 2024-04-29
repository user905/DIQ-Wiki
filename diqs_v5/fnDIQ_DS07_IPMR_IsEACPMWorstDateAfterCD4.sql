/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PM EAC Worst Date Later Than CD-4</title>
  <summary>Is the PM EAC Worst date later than the CD-4 milestone date?</summary>
  <message>EAC_PM_worst_date &gt; DS04.EF_date where milestone_level = 190 (FC only).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070353</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMWorstDateAfterCD4] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_worst_date > (
			SELECT MIN(EF_date)
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'FC' and milestone_level = 190
		)
)