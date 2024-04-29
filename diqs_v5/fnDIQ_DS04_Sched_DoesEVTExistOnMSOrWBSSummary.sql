/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Summary Task or Milestone with EVT</title>
  <summary>Does this WBS Summary task or Start/Finish Milestone have an EVT?</summary>
  <message>EVT found (EVT &lt;&gt; null or blank) on WBS Summary task or Start/Finish Milestone (type = SM, FM, or WS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040124</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesEVTExistOnMSOrWBSSummary] (
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
		AND type IN ('SM','FM','WS')
		AND ISNULL(EVT,'') <> ''
)