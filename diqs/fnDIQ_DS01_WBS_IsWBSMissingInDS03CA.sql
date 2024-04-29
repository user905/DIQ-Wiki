/*

The name of the function should include the ID and a short title, for example: DIQ0001_WBS_Pkey or DIQ0003_WBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_WBS" or "FF26_WBS_EU".
DIQ tests might pull data from multiple tables but should only return rows from one table (split up the tests if needed).
This value is the table from which this row returns tests.

status should be set to TEST, LIVE, SKIP.
TEST indicates the test should be run on test/development DIQ checks.
LIVE indicates the test should run on live/production DIQ checks.
SKIP indicates this isn't a test and should be skipped.

severity should be set to WARNING or ERROR. ERROR indicates a blocking check that prevents further data processing.

summary is a summary of the check for a technical audience.

message is the error message displayed to the user for the check.

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
    -- Check for missing, non-external WBS IDs in DS03 where type = CA or SLPP
    -- If in DS03, must have budget.
  WITH DS03 AS (
      SELECT DISTINCT WBS_ID_CA
      FROM DS03_cost
      WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
  )

  SELECT DS01.*
  FROM DS01_WBS AS DS01 LEFT JOIN DS03 ON DS01.WBS_ID = DS03.WBS_ID_CA
  WHERE   DS01.upload_ID = @upload_ID 
      AND DS01.type in ('CA', 'SLPP')
      AND DS01.[external] = 'N'
      AND DS03.WBS_ID_CA IS NULL


	-- SELECT 
	-- 	* 
	-- FROM 
	-- 	DS01_WBS 
	-- WHERE 
	-- 		  upload_ID = @upload_ID 
	-- 	AND type in ('CA', 'SLPP')
  --   AND [external] = 'N'
  --   AND WBS_ID NOT IN (
  --     SELECT WBS_ID_CA
  --     FROM DS03_cost
  --     WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
    -- )
)