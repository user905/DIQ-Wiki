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
  <id>10</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Parent Lower in WBS Hierarchy than Child</title>
  <summary>Is the parent lower in the WBS hierarchy than its child?</summary>
  <message>Parent found at a lower level in the WBS hierarchy than its child, i.e. Parent Level &gt; Child Level.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010025</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsParentLowerInWBSHierarchyThanChild] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(




    --Insert statements for procedure here
	--NOTE: higher here means higher in the tree, which means a lower number. We are therefore looking for a child with a level < its parent
	SELECT 
		Child.* 
	FROM 
		DS01_WBS Child,
		(SELECT WBS_ID, [Level] FROM DS01_WBS WHERE upload_ID=@upload_ID) Parent
	WHERE 
			upload_ID = @upload_ID
		AND Child.parent_WBS_ID=Parent.WBS_ID
		AND Child.[Level]<=Parent.[Level]
)