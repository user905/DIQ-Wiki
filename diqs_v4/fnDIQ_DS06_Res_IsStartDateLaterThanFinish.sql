/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Start Date Later Than Finish Date</title>
  <summary>Is the start date later than the finish date for this resource?</summary>
  <message>Resource start_date &gt; finish_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060255</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsStartDateLaterThanFinish] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND start_date > finish_date
)