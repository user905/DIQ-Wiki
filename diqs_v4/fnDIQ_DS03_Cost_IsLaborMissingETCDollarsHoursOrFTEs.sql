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
  <title>Labor Missing Estimates</title>
  <summary>Is this Labor missing Estimated Dollars, Hours, or FTEs?</summary>
  <message>EOC = Labor with ETCi &lt;&gt; 0 for either Dollars, Hours, or FTEs, but where at least one other ETCi = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030091</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborMissingETCDollarsHoursOrFTEs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for Labor where Estimates has been recorded on one of the three ETCi fields,
		but not the others.
		It does this by filtering for any EOC = Labor row with ETCi Dollars, Hours, or FTEs <> 0,
		and any row with ETCi Dollars, Hours, or FTEs = 0.

		The ORs between each of the ETCi types allows this to work for any combination. 
		E.g. ETCi_Dollars <> 0 & ETCi_FTEs = 0.
	*/
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND EOC = 'Labor'
		AND (ETCi_dollars <> 0 OR ETCi_FTEs <> 0 OR ETCi_hours <> 0)
		AND (ETCi_dollars = 0 OR ETCi_FTEs = 0 OR ETCi_hours = 0)
)