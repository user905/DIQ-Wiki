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
  <severity>ERROR</severity>
  <title>Duplicate VAR</title>
  <summary>Is this VAR duplicated by WBS ID &amp; Narrative type?</summary>
  <message>Count of WBS_ID &amp; narrative_type combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110495</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for primary key violations in the table.
    The PK is defined by WBS_ID and narrative_type (if exists).
	*/
  with Dupes as (
    SELECT WBS_ID, ISNULL(narrative_type,'') narrative_type
    FROM DS11_variance
    WHERE upload_ID = @upload_ID
    GROUP BY WBS_ID, ISNULL(narrative_type,'')
    HAVING COUNT(*) > 1
  )

	SELECT
		V.*
	FROM 
		DS11_variance V INNER JOIN Dupes D ON V.WBS_ID = D.WBS_ID 
                                      AND ISNULL(V.narrative_type,'') = D.narrative_type
	WHERE 
			upload_ID = @upload_ID
)