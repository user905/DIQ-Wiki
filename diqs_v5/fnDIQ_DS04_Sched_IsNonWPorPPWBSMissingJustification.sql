/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Justification Missing</title>
  <summary>Is non-WP, PP, or SLPP WBS type missing a justification?</summary>
  <message>Non-WP/PP/SLPP type (DS01.type &lt;&gt; WP, PP, or SLPP) is missing a value in justification_WBS.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040198</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsNonWPorPPWBSMissingJustification] (
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
        upload_ID = @upload_id
    AND TRIM(ISNULL(justification_WBS, '')) = ''
    AND WBS_ID IN (
      SELECT WBS_ID
      FROM DS01_WBS
      WHERE upload_ID = @upload_id AND [type] NOT IN ('Wp', 'PP', 'SLPP')
    )
)