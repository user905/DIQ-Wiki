/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>ZBA Not Coded As Subcontract Alignment Milestone</title>
  <summary>Should this ZBA be coded as a subcontract alignment milestone?</summary>
  <message>ZBA subtype (subtype = ZBA) found on non-subcontract alignment milestone (milestone_level &lt;&gt; 8xx).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040226</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsZBANotMSLevel8xx] (
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
		AND ISNULL(subtype,'') = 'ZBA'
		AND milestone_level NOT BETWEEN 800 AND 899
)