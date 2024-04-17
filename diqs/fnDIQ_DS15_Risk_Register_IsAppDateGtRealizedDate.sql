/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Approved Date After Realized Date</title>
  <summary>Is the approved date after the realized date?</summary>
  <message>approved_date &gt; realized_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150550</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsAppDateGtRealizedDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS15_risk_register
	WHERE 
			upload_ID = @upload_ID 
		AND approved_date > realized_date
)