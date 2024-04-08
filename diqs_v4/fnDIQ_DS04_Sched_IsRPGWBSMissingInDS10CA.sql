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
  <severity>ALERT</severity>
  <title>Reprogramming Missing in CC Log Detail (CA)</title>
  <summary>Is this Work or Planning Planning with reprogramming missing in the CC Log detail?</summary>
  <message>WBS_ID where RPG = Y not found in DS10.WBS_ID list (compare by DS01.parent_WBS_ID where parent is of type CA or SLPP).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040279</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsRPGWBSMissingInDS10CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for CA WBSs with RPG that are not logged in DS10. 
		It returns rows only if the DS10 WBS IDs are at the CA/SLPP level, which we check first.

		To do this, first collect WBS_IDs from DS10 in cte, CCLog.
		
		Then get CA WBS IDs with RPG by joining AncestryTree_Get to DS04 by WBS_ID and filtering for
		WP/PP types with CA/SLPP ancestors & DS04.rpg = Y.

		Compare the two in a third cte, Flags, to see which CAs are the problem,
		and return WP WBS ID's to join back to DS04 for final output.

		Finally, return from DS04, but only if there are WADs at the CA level.
	*/
	with CCLog as (
		--CC log WBS IDs
		SELECT WBS_ID
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
	), CARPG as (
		--CA & WP WBSs with RPG
		SELECT A.Ancestor_WBS_ID CAWBS, S.WBS_ID WPWBS
		FROM DS04_schedule S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE S.upload_ID = @upload_ID AND A.[Type] IN ('PP','SLPP') AND A.Ancestor_Type IN ('CA','SLPP') AND RPG = 'Y'
		GROUP BY A.Ancestor_WBS_ID, S.WBS_ID
	), Flags as (
		--Composite, joined by CA WBS ID. 
		--Missed joins are CAs without CC log entries.
		--Output is by WP WBS ID to join back to DS04.
		SELECT WPWBS
		FROM CARPG RPG LEFT OUTER JOIN CCLog C ON RPG.CAWBS = C.WBS_ID
		WHERE C.WBS_ID IS NULL
	)


	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Flags F ON S.WBS_ID = F.WPWBS
	WHERE
		S.upload_ID = @upload_ID
		AND (--return only if there are WADs at the CA level.
				SELECT COUNT(*) 
				FROM DS10_CC_log_detail 
				WHERE upload_ID = @upload_ID 
				AND WBS_ID IN (
					SELECT WBS_ID
					FROM DS01_WBS
					WHERE upload_ID = @upload_ID AND type IN ('CA','SLPP')
				)
		) > 0
)