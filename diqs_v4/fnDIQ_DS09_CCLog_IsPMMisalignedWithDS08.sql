/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Misaligned with WADs</title>
  <summary>Is the PM name misaligned with what is in the WADs?</summary>
  <message>PM &lt;&gt; DS08.PM where approved_date &gt; CPP_SD_Date - 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090446</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsPMMisalignedWithDS08] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with LastPeriod as (
		SELECT period_date
			FROM (
			SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date DESC) AS row_num
			FROM DS03_cost
			WHERE upload_ID = @upload_ID AND period_date < CPP_status_date
			) subquery
		WHERE row_num = 1
	), WADs as (
		SELECT *
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM 
		DS09_CC_log
	WHERE 
			upload_ID = @upload_ID
		AND approved_date > (SELECT TOP 1 period_date FROM LastPeriod)
		AND PM NOT IN (
			SELECT PM
			FROM WADs
			WHERE auth_PM_date > (SELECT TOP 1 period_date FROM LastPeriod)
		)
		AND (SELECT COUNT(*) FROM WADs) > 0 -- run only if there are WADs
)