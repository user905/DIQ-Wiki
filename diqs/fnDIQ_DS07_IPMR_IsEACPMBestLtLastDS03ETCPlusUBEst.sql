/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PM EAC Best Date Misaligned with Cost Estimates</title>
  <summary>Is the PM EAC Best date earlier than the last recorded ETC plus estimated UB?</summary>
  <message>EAC_PM_best_date &lt; last DS03.period_date where ETCi &gt; 0 (hours, dollars, or FTEs) + DS07.UB_EST_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070303</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMBestLtLastDS03ETCPlusUBEst] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with LastETCi as (
		SELECT MAX(period_date) LastPrd
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND (ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0)
	), UBEstWkndFactor as (
		SELECT (ISNULL(UB_est_days,0) / 5) * 2 WkndF
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_best_date < DATEADD(day, (SELECT TOP 1 WkndF FROM UBEstWkndFactor), (SELECT TOP 1 LastPrd FROM LastETCi))
)