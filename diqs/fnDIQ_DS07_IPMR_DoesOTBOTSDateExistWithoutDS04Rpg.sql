/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>OTB / OTS Without Schedule Reprogramming</title>
  <summary>Is there an OTB/OTS date without schedule reprogramming?</summary>
  <message>OTB_OTS_date is not null/blank &amp; COUNT(DS04.RPG = Y) = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070340</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoesOTBOTSDateExistWithoutDS04Rpg] (
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
		AND (SELECT COUNT(*) FROM DS04_schedule	WHERE upload_ID = @upload_ID AND RPG = 'Y') = 0
		AND OTB_OTS_date IS NOT NULL
)