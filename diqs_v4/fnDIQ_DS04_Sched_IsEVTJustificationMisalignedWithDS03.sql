/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EVT Justification Misaligned With Cost</title>
  <summary>Is a similar justification for this EVT missing in cost?</summary>
  <message>EVT Justification found on FC task without a related justification in cost (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040277</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEVTJustificationMisalignedWithDS03] (
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
			upload_id = @upload_ID
		AND schedule_type = 'FC'
		AND EVT in ('B', 'G', 'H', 'J', 'L', 'M', 'N', 'O', 'P')
		AND TRIM(ISNULL(justification_EVT,'')) <> ''
		AND WBS_ID IN (
			SELECT WBS_ID_WP
			FROM DS03_cost
			WHERE upload_ID = @upload_ID AND TRIM(ISNULL(justification_EVT,''))=''
		)
)