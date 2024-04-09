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
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Estimate Uncertainty Entry</title>
  <summary>Is this WBS / EOC combo duplicated?</summary>
  <message>Count of combo WBS &amp; EOC combo &gt; 1.</message>
  <grouping>WBS_ID,EOC</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1170582</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for primary key violations in the table.
		The PK is defined as the combination of WBS_ID and EOC.
	*/
	with Dupes as (
		SELECT WBS_ID ,EOC
		FROM DS17_WBS_EU
		WHERE upload_id = @upload_ID
		GROUP BY WBS_ID, EOC
		HAVING COUNT(*) > 1
	)

	SELECT 
		E.*
	FROM 
		DS17_WBS_EU E INNER JOIN Dupes D ON E.WBS_ID = D.WBS_ID 
										AND E.EOC = D.EOC
	WHERE 
		upload_ID = @upload_ID
)