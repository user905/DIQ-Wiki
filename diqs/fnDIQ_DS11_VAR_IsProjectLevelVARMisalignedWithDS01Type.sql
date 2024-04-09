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
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Project-Level VAR Misaligned With Project-Level WBS</title>
  <summary>Is this project-level VAR not at Level 1 in the WBS Hierarchy?</summary>
  <message>narrative_type &lt; 200 &amp; DS01.level &gt; 1 (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110490</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsProjectLevelVARMisalignedWithDS01Type] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks VARs with narrative types < 200 that are not of DS01.level = 1
		To do this, we cast the narrative_type to an int and look for values < 200
		(NOTE: we use ISNULL(narrative_type,'1000') to ensure that missing values are not caught by the
		< 200 filter).

		Then, join to DS01 by WBS_ID and filter for level <> 1
	*/
	SELECT
		V.*
	FROM 
		DS11_variance V INNER JOIN DS01_WBS W ON V.WBS_ID = W.WBS_ID
	WHERE 
			V.upload_ID = @upload_ID
		AND W.upload_ID = @upload_ID
		AND CAST(ISNULL(narrative_type,'1000') as int) < 200 
		AND W.[level] <> 1
)