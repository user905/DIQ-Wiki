/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM EAC Dates Chronology Issue</title>
  <summary>Are the PM EAC dates chronologically ordered as best, likely, worst?</summary>
  <message>EAC_PM_best_date &gt;= EAC_PM_likely_date OR EAC_PM_likely_date &gt;= EAC_PM_worst_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070267</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_ArePMEACDatesChronological] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
			EAC_PM_best_date >= EAC_PM_likely_date OR 
			EAC_PM_likely_date >= EAC_PM_worst_date
		)
)