/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Labor Resource Lacking Appropriate EOC</title>
  <summary>Is the EOC for this labor type resource something other than Labor or Overhead?</summary>
  <message>type = labor where EOC &lt;&gt; Labor or Overhead.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060256</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborTypeAndEOCMismatched] (
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
		AND type = 'Labor'
		AND EOC NOT IN ('Labor','Overhead')
)