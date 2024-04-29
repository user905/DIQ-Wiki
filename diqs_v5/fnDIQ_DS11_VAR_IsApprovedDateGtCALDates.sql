/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Approved Date After CAL Dates</title>
  <summary>Is the approved date for this variance later than the dates for the corrective action date?</summary>
  <message>approved_date &gt; DS12.initial_date, DS12.original_due_date, DS12.forecast_due_date, or DS12.closed_date (by CAL_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110482</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsApprovedDateGtCALDates] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with VARsByCAL as (
		SELECT WBS_ID, approved_date, CAL_ID 
		FROM DS11_variance CROSS APPLY string_split(CAL_ID, ';')
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT WBS_ID
		FROM VARsByCAL V INNER JOIN DS12_variance_CAL C ON V.CAL_ID = C.CAL_ID
														AND (
																V.approved_date > C.initial_date 
															OR V.approved_date > C.original_due_date 
															OR V.approved_date > C.forecast_due_date 
															OR V.approved_date > C.closed_date
														)
		WHERE C.upload_ID = @upload_ID
	)
	SELECT 
		V.*
	FROM 
		DS11_variance V INNER JOIN Flags F ON V.WBS_ID = F.WBS_ID
	WHERE 
		V.upload_ID = @upload_ID 
)