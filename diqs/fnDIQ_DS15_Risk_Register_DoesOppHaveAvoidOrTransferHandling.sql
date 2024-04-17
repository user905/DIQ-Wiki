/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Opportunity With Avoid Or Transfer Handling Type</title>
  <summary>Does this opportunity have an avoid or transfer handling type?</summary>
  <message>type = O &amp; risk_handling = Avoid or Transfer.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150548</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_DoesOppHaveAvoidOrTransferHandling] (
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
		AND type = 'O'
		AND risk_handling IN ('avoid', 'transfer')
)