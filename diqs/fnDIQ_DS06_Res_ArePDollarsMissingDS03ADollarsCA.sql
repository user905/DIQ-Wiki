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
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Performance without Cost Actuals (CA)</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC, at the CA level)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC (CA level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060304</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		UPDATE: Nov 2023. This DIQ, along with fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsWP, replaced fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollars.
		Note that with Scenario D, this will flag for all rows that should tie out to WPs in DS03 with is_indirect = N. This is because Scenario D
		has Indirect Actuals at the CA level and Direct Actuals at the WP level, and testing them together is exceedingly difficult.

		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 & DS06 EOC fields cannot be joined directly, since rows can exist in DS03 with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		The workaround is to use a CASE statemend on DS03.EOC: CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC.
		This returns 'Indirect' for any row where is_indirect = Y, and the EOC for any other row.

		This function looks for resources where resource performance (P6 calls this actual_dollars) exists but Actuals (ACWP) have not been recorded in DS03 at the CA level.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		Step 1. Collect DS03 Control Account data with ACWPi in cte, CostCAs.

		Step 2. In cte, ScheduleWBS, join DS04 to DS06 by task ID & subproject ID to get resource performance, broken out by EOC and by Schedule WBS ID, 
		and filter for SUM(performance) > 0 (Forecast only)

		Step 3. In cte, WBSHierarchy, collect the WBS Hierarchy.

		Step 4. In cte, ScheduleCAs, join ScheduleWBS to WBSHierarchy to get the schedule data by CA WBS.

		Step 5. In cte, FlagsByCAWBS, join the cost CA data to the Schedule CA data and filter for any missed joins or where the Cost CAs
		are missing ACWPi dollars.

		These are the problem CAs.

		Step 6. In cte, FlagsByWPWBS, take the problem CAs and join back to WBSHierarchy to get the problem WPs

		Step 7. In cte, FlagsByTask, join back to DS04 schedule to ge