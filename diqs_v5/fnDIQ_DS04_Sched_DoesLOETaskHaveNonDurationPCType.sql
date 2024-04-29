/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>LOE Task without Duration % Complete</title>
  <summary>Does this LOE task have a % Complete type other than Duration?</summary>
  <message>LOE Task (EVT = A or type = LOE) with % Complete type &lt;&gt; Duration (PC_type &lt;&gt; Duration).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040126</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesLOETaskHaveNonDurationPCType] (
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
		AND PC_type <> 'Duration'
		AND (EVT = 'A' OR [type] = 'LOE')
)