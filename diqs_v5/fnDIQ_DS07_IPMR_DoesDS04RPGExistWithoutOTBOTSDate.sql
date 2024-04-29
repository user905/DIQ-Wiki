/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>RPG without OTB/OTS Date</title>
  <summary>Are there RPG tasks without an OTB/OTS Date?</summary>
  <message>DS04 tasks with RPG = Y found without DS07.OTB_OTS_Date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070310</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoesDS04RPGExistWithoutOTBOTSDate] (
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
		AND (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND RPG = 'Y') > 0
		AND OTB_OTS_date IS NULL
)