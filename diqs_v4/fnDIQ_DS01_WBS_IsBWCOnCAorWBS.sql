/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>BWC ID Found on CA or WBS</title>
  <summary>Is there a BWC ID for a WBS element of type CA or WBS?</summary>
  <message>BWC ID found on WBS element of type CA or WBS</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010013</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsBWCOnCAorWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS01_WBS
	WHERE
			upload_ID = @upload_ID
		AND ISNULL(BWC_ID,'') <> ''
		AND type IN ('CA','WBS')
)