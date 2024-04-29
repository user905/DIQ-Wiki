/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Missing from Cost</title>
  <summary>Is this WP or PP WBS ID missing in cost?</summary>
  <message>WBS_ID where type = WP or PP missing in DS03.WBS_ID_WP list (where BCWSi_Dollars, Hours, or FTEs &gt; 0).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010013</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWBSMissingInDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  WITH DS03WBS AS (
      SELECT DISTINCT WBS_ID_WP WBS
      FROM DS03_cost
      WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
  )
  SELECT W.*
  FROM DS01_WBS AS W LEFT JOIN DS03WBS AS C ON W.WBS_ID = C.WBS
  WHERE   W.upload_ID = @upload_ID 
      AND W.type in ('WP', 'PP')
      AND W.[external] = 'N'
      AND C.WBS IS NULL
)