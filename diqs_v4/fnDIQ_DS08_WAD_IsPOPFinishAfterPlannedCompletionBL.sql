/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Finish After Project Planned Completion Milestone</title>
  <summary>Is the POP finish later than the planned completion milestone?</summary>
  <message>pop_finish &gt; DS04.ES_date/EF_date where milestone_level = 170 &amp; schedule_type = BL.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080604</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishAfterPlannedCompletionBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID  
		AND POP_finish_date > (
			SELECT COALESCE(ES_Date, EF_Date)
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND milestone_level = 170 AND schedule_type = 'BL'
		)
)