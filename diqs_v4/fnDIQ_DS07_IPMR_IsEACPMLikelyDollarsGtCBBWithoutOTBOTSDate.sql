/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM EAC Likely Dollars &amp; CBB Issue</title>
  <summary>Are the PM EAC likely dollars greater than the CBB without an OTB/OTS?</summary>
  <message>EAC_PM_likely_dollars &gt; CBB_dollars where OTB_OTS_date is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070270</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMLikelyDollarsGtCBBWithoutOTBOTSDate] (
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
		AND EAC_PM_likely_dollars > CBB_dollars
		AND OTB_OTS_date IS NULL
)