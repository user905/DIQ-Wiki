/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Replan or Repgramming Milestone Without OTB/OTS Date</title>
  <summary>Does this replanning or reprogramming milestone exist without an OTB/OTS Date?</summary>
  <message>Replan or repgroamming milestone found (milestone_level = 138 or 139) without an OTB/OTS Date (DS07 OTB_OTS_Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040129</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesReplanOrReprogrammingMSExistWithoutOTBOTSDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND milestone_level IN (138,139)
		AND (SELECT OTB_OTS_date FROM DS07_IPMR_header WHERE upload_ID = @upload_ID) IS NULL
)