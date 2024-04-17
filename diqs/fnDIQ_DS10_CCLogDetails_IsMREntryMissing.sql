/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>MR Entry Missing in CC Log Detail</title>
  <summary>Are there no MR entries in the CC Log detail?</summary>
  <message>Count where category = MR is 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1100479</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsMREntryMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with CCLogDetail as (
    SELECT *
    FROM DS10_CC_log_detail 
    WHERE upload_ID = @upload_id
  )
	SELECT 
        *
    FROM 
        DummyRow_Get(@upload_id)
    WHERE 
            NOT EXISTS (SELECT 1 FROM CCLogDetail WHERE category = 'MR')
        AND (SELECT COUNT(*) FROM CCLogDetail) > 0 --run only if rows exist in DS10
)