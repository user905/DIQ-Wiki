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
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SS or FF Improperly Linked With Other Relationship Types</title>
  <summary>Does this SS or FF relationship exist alongside an FS or SF relationship?</summary>
  <message>Predecessor has at least one SS or FF relationship (type = SS or FF) and one non-SS or non-FF relationship tied to it (type = SF or FS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1050234</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsSSorFFRelTypeImproperlyLinked] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for SS or FF relationship types that are attached to a task 
		that also has SF or FS types, i.e. SS & FFs can exist only with each other.

		Step 1. Using cte, Flags, collect predecessors by schedule_type and pred_subproject, and concatenate rel types
		into a single field using STRING_AGG.

		Step 2. Use the results to join back to DS05 by schedule_type, predecessor, and predecessor_subproject, 
		and filter for any of the following combinations:
		1. SS with FS (or vice versa)
		2. SS with SF (or vice versa)
		3. FF with FS (or vice versa)
		4. FF with SF (or vice versa)
	*/

	with Flags as (
		SELECT schedule_type, predecessor_task_ID, ISNULL(predecessor_subproject_ID,'') PSubP, STRING_AGG(type, ',') WITHIN GROUP (ORDER BY type) Type
		FROM DS05_schedule_logic
		WHERE upload_ID = @upload_ID
		GROUP BY schedule_type, predecessor_task_ID, ISNULL(predecessor_subproject_ID,'')
	)

	SELECT L.*
	FROM DS05_schedule_logic L INNER JOIN Flags F 	ON L.schedule_type = F.schedule_type
													AND L.predecessor_task_ID = F.predecessor_task_ID
													AND ISNULL(L.predecessor_subproject_ID,'') = F.PSubP
	WHERE upload_ID = @upload_ID
		AND (
				F.[Type] LIKE '%SS%FS%'
			OR	F.[Type] LIKE '%FS%SS%'
			OR	F.[Type] LIKE '%SS%SF%'
			OR	F.[Type] LIKE '%SF%SS%'
			OR 	F.[Type] LIKE '%FF%FS%'
			OR 	F.[Type] LIKE '%FS%FF%'
			OR 	F.[Type] LIKE '%FF%SF%'
			OR 	F.[Type] LIKE '%SF%FF%'
		)
)