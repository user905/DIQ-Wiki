/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Milestone % Complete Not Equal To 0 Or 100%</title>
  <summary>Does this milestone have a % Complete other than 0 or 100%?</summary>
  <message>Milestone (type = SM or FM) with a % complete other than 0 or 100% (pc_duration, pc_units, pc_physical).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040128</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesMSHavePCNEqTo0Or1] (
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
		AND type IN ('SM','FM')
		AND (
			(PC_duration <> 0 AND PC_duration <> 1) OR 
			(PC_physical <> 0 AND PC_physical <> 1) OR
			(PC_units <> 0 AND PC_units <> 1)
		) 
)