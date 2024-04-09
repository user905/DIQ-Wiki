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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Reprogramming Without OTB/OTS Date</title>
  <summary>Is there BAC, CV, or SV repgrogramming but not OTB/OTS Date?</summary>
  <message>BAC_rpg, CV_rpg, or SV_rpg &lt;&gt; 0 but without OTB_OTS_Date in DS07 (IPMR Header).</message>
  <grouping>PARSID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030070</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesRPGExistWithoutDS07OTBOTSDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This DIQ looks for the existence of any RPG values (BAC, SV, CV) when a DS07.OTB_OTS_Date does not exist.
		To do so, it simply checks if there is an OTB/OTS date and, if not, returns any rows with BAC/CV/SV_rpg <> 0.
	*/
    SELECT	*
    FROM	DS03_Cost
    WHERE	upload_ID = @upload_id
			AND (BAC_rpg <> 0 OR CV_rpg <> 0 OR SV_rpg <> 0)
			AND EXISTS(
				SELECT	*
				FROM	DS07_IPMR_header
				WHERE	upload_ID = @upload_id
						AND OTB_OTS_Date IS NULL
			)
)