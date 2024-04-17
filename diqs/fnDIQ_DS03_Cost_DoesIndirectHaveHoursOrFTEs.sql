/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Indirect With Hours and/or FTEs</title>
  <summary>Does this indirect have hours or FTEs?</summary>
  <message>EOC = 'Indirect' or is_indirect = 'Y' AND (BCWSi, BCWPi, ACWPi, or ETCi hours or FTEs &gt; 0)</message>
  <grouping></grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030114</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesIndirectHaveHoursOrFTEs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT * 
	FROM DS03_Cost
	WHERE 	upload_ID = @upload_ID
		AND (EOC = 'Indirect' or is_indirect = 'Y')
		AND (
        BCWSi_hours > 0 OR BCWSi_FTEs > 0 OR 
        BCWPi_hours > 0 OR BCWPi_FTEs > 0 OR 
        ACWPi_hours > 0 OR ACWPi_FTEs > 0 OR 
        ETCi_hours > 0 OR ETCi_FTEs > 0
      )
)