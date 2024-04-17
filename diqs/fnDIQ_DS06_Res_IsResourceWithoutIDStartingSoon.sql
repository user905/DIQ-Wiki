/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Task without Resource Assigned Starting Soon</title>
  <summary>Is this task lacking a resource ID planned to start soon (within 3 months)?</summary>
  <message>Resource item without an ID is planned to start within three months (resource_ID is blank &amp; start_date is within 3 months of CPP SD).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060251</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceWithoutIDStartingSoon] (
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
		AND role_ID IS NOT NULL
		AND ISNULL(resource_ID,'') = ''
		AND DATEDIFF(d,CPP_status_date,start_date) < 90
)