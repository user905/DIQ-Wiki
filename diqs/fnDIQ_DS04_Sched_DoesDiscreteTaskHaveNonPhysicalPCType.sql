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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Discrete Task Without Non-Physical % Complete Type</title>
  <summary>Does this discrete task have a % Complete type that is not Physical?</summary>
  <message>Discrete Task (EVT = B, C, D, E, F, G, H, L, N, O, P) with % Complete type &lt;&gt; Physical (PC_type &lt;&gt; Physical).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040123</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesDiscreteTaskHaveNonPhysicalPCType] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for Discrete EVTs:
			MSs (B), 
			% Complete tasks (C), 
			units complete (D),
			50-50 (E), 
			0-100 (F), 
			100-0 (G), 
			variation of 50-50 (H), 
			assignment percent complete (L),
			steps (N), 
			earned as spent (O), p
			ercent manual entry (P)
		that do not have a physical % complete type.
	*/

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND PC_type <> 'physical'
		AND EVT in ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P')
)