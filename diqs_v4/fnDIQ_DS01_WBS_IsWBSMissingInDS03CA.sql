/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA or SLPP Missing from Cost</title>
  <summary>Is this CA or SLPP WBS ID missing in cost?</summary>
  <message>WBS_ID where type = CA or SLPP missing in DS03.WBS_ID_CA list (where BCWSi_Dollars, Hours, or FTEs &gt; 0).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010014</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWBSMissingInDS03CA] (
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
		AND type in ('CA', 'SLPP')
    AND WBS_ID NOT IN (
      SELECT WBS_ID_CA
      FROM DS03_cost
      WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
    )
)