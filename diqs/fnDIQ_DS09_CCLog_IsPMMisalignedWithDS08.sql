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
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Misaligned with WADs</title>
  <summary>Is the PM name misaligned with what is in the WADs?</summary>
  <message>PM &lt;&gt; DS08.PM where approved_date &gt; CPP_SD_Date - 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090446</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsPMMisalignedWithDS08] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for discrepancies btw the PM name and the DS08 PM name
		for WADs and their latest CC log changes.

		The check is only for the current period, which is everything between the CPP SD
		and the previous DS03.period_date.

		To get the previous CPP SD (from DS03), we use ROW_NUMBER (sorted by DESC), 
		filter for all CPP SDs < CPP_status_date,
		and grab the first row.

		Once we have the previous period, we simply use it to filter:
		1. DS09.approved_date > last period SD
		2. DS09.PM NOT IN (DS08.PM list where auth_PM_date > last period SD)

		Run this DIQ only if DS08 has rows.
	*/

	with LastPeriod as (
		SELECT period_date
			FROM (
			SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date DESC) AS row_num
			FROM DS03_cost
			WHERE upload_ID = @upload_ID AND period_date < CPP_status_date
			) subquery
		WHERE row_num = 1
	), WADs as (
		SELECT *
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM 
		DS09_CC_log
	WHERE 
			upload_ID = @upload_ID
		AND approved_date > (SELECT TOP 1 period_date FROM LastPeriod)
		AND PM NOT IN (
			SELECT PM
			FROM WADs
			WHERE auth_PM_date > (SELECT TOP 1 period_date FROM LastPeriod)
		)
		AND (SELECT COUNT(*) FROM WADs) > 0 -- run only if there are WADs
)