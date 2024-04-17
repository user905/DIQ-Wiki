/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Discrete Task Without Non-Physical % Complete Type</title>
  <summary>Does this discrete task have a % Complete type that is not Physical?</summary>
  <message>Discrete Task (EVT = B, C, D, E, F, G, H, L, N, O, P) with % Complete type &lt;&gt; Physical (PC_type &lt;&gt; Physical).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040123</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesDiscreteTaskHaveNonPhysicalPCType] (
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
		AND PC_type <> 'physical'
		AND EVT in ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P')
)