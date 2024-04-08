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
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CAL ID Missing</title>
  <summary>Is the CAL ID missing for this VAR?</summary>
  <message>CAL_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110484</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsCALIDMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for missing CAL_IDs
	*/
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(CAL_ID,'')) = ''

/*
EXAMPLE

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

  DECLARE @cpp DATE = '2022-02-28';


	SELECT period_date
			FROM (
			SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date DESC) AS row_num
			FROM #my_data
			WHERE period_date < @cpp
			) subquery
		WHERE row_num = 1
		--ORDER BY period_date DESC



-- Drop the temporary table
DROP TABLE #my_data;

*/


)