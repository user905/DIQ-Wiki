/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Initial Date After Original Due Date</title>
  <summary>Is the initial date for this corrective action after the original due date?</summary>
  <message>initial_date &gt; original_due_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1120498</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_IsInitDateGtOriginalDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS12_variance_CAL
	WHERE 
			upload_ID = @upload_ID
		AND initial_date > original_due_date
)