/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>12 Months Since OTB-OTS Without BCP</title>
  <summary>Has it been twelve months since an OTB-OTS date without a BCP?</summary>
  <message>Minimum 12 month delta between CPP status date &amp; OTB_OTS_date without DS09.type = BCP or DS04.milestone_level between 131 &amp; 135.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070365</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsOTBOTSDateOverdue] (
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
		AND (
				(SELECT COUNT(*) FROM DS09_CC_log WHERE upload_ID = @upload_ID AND type = 'BCP') = 0
			OR (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_id AND milestone_level BETWEEN 131 AND 135) = 0
		)
		AND DATEDIFF(m,CPP_status_date,OTB_OTS_date) < -12
)