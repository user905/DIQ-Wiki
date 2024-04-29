/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS00 Metadata</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>CPP Status Date Missing From Cost Periods</title>
  <summary>Is the CPP Status Date missing from the period dates in the cost file?</summary>
  <message>DS00.CPP_Status_Date not in DS03.period_date list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1000001</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS00_Meta_IsCPPMissingInDS03PeriodDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(	/*
		Check to see if the CPP Status Date exists in the DS03.period_dates list. 
		To do this, look to see if any rows exist where DS03.cpp_status_date = DS03.period_date.
		Do not flag if the CPP Status Date is after the last period_date in the cost file.
	with Periods as (
		SELECT cpp_status_date, period_date
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM 
		DummyRow_Get(@upload_ID)
	WHERE 
			(SELECT COUNT(*) FROM Periods WHERE period_date = CPP_status_date) = 0
		AND (SELECT COUNT(*) FROM Periods WHERE cpp_status_date > (SELECT MAX(period_date) from periods)) = 0
)