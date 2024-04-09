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
  <severity>ALERT</severity>
  <title>Implementation Date Missing or Unreasonable</title>
  <summary>Is the implementation date missing or is it considerably after the approved date?</summary>
  <message>implementation_date is missing or &gt; the next DS03.period_date after the current DS09.approved_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090445</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsImpDateMissingOrUnreasonable] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CC Log IDs where:
		1. implementation_date = blank/null OR 
		2. implementation_date > period of current approved_date & next period
		
		[Intent: implementation_date must be within the reporting period of the approved date 
		or the next reporting period; which are based on DS03.period_date]

		To accomplish #2 above, we use ROW_NUMBER:
		The innermost subquery retrieves the list of DS03.period_dates that are greater than the 
		DS09.approved_date, and then uses the ROW_NUMBER() function to assign a row number to each date in 
		ascending order. The outer subquery gets the second row (where row_num = 2),
		which is the one two compare to implementation date.
	*/

	SELECT 
		*
	FROM
		DS09_CC_log
	WHERE
			upload_ID = @upload_ID  
		AND (
			implementation_date IS NULL OR
			implementation_date > (
				SELECT period_date
				FROM (
					SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date ASC) AS row_num
					FROM DS03_cost
					WHERE upload_ID = @upload_ID AND period_date >= approved_date
				) subQ
				WHERE row_num = 2
			)
		)

/*
		Example:

		-- Create a temporary table to hold the sample data
		CREATE TABLE #my_data (
		period_date DATE,
		cost DECIMAL(18, 2)
		);

		-- Insert some sample data into the table
		INSERT INTO #my_data (period_date, cost)
		VALUES 
		('2021-01-01', 100.00),
		('2021-02-01', 110.00),
		('2021-03-01', 120.00),
		('2021-04-01', 130.00),
		('2021-05-01', 140.00),
		('2021-06-01', 150.00),
		('2021-07-01', 160.00),
		('2021-08-01', 170.00),
		('2021-09-01', 180.00),
		('2021-10-01', 190.00),
		('2021-11-01', 200.00),
		('2021-12-01', 210.00),
		('2022-01-01', 220.00),
		('2022-02-01', 230.00),
		('2022-03-01', 240.00),
		('2022-04-01', 250.00),
		('2022-05-01', 260.00),
		('2022-06-01', 270.00),
		('2022-07-01', 280.00),
		('2022-08-01', 290.00),
		('2022-09-01', 300.00);


		DECLARE @approved_date DATE = '2022-01-01';

		SELECT period_date
		FROM (
		SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date ASC) AS row_num
		FROM #my_data
		WHERE period_date >= @approved_date
		) subquery
		WHERE row_num = 2
		ORD