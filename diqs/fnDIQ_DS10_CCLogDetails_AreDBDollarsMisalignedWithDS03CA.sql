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
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>DB Dollar Transactions Misaligned with Cost (CA)</title>
  <summary>Do the DB transaction dollars for this Control Account sum to something other than the DB in cost?</summary>
  <message>Sum of dollars_delta where category = DB &lt;&gt; Sum of DS03.BCWSi_dollars (by WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100453</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreDBDollarsMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether CA-level DB transactions sum to the DS03.DB.
		Comparison is by WBS_ID.

		To do this, we create a cte, Flags, with two sub-queries:
		1. DS03 data with CA WBS IDs and their DBs (SUM(BCWSi))
		2. DS10 data with DB transactions and the sum of their delta dollars

		We then join these by DS03.WBS_ID_CA = DS10.WB_ID and compare.
		Any resulting rows are failed WBS_IDs.
		(Note: This will return no results if DB-level transactions are at the WP/PP level because
		the DS10.WBS_IDs will not match with the DS03.WBS_ID_CA. This is why there is another version
		of this DIQ at the WP level.)
	*/
	with Flags as (
		SELECT CCDB.WBS_ID
		FROM ( --cost DB by CA BWS
				SELECT 
					WBS_ID_CA, SUM(BCWSi_dollars) DB
				FROM DS03_cost
				WHERE upload_ID = @upload_ID
				GROUP BY WBS_ID_CA
			) CostDB INNER JOIN (
				-- CC log DB by WBS ID (possibly CA, possibly not)
				SELECT WBS_ID, SUM(dollars_delta) DB
				FROM DS10_CC_log_detail
				WHERE upload_ID = @upload_ID AND category = 'DB'
				GROUP BY WBS_ID
			) CCDB ON CostDB.WBS_ID_CA = CCDB.WBS_ID
		WHERE
			CostDB.DB <> CCDB.DB
	)

	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND category = 'DB'
	AND WBS_ID IN (
		SELECT WBS_ID FROM Flags
	)
)