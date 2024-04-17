/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>OTB / OTS Without BAC Reprogramming</title>
  <summary>Is there an OTB/OTS date without BAC reprogramming?</summary>
  <message>OTB_OTS_date is not null/blank &amp; SUM(DS03.BAC_rpg) = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070338</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoesOTBOTSDateExistWithoutBACRpg] (
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
		AND (SELECT SUM(ISNULL(BAC_rpg,0)) FROM DS03_cost WHERE upload_ID = @upload_ID) = 0
		AND OTB_OTS_date IS NOT NULL
)