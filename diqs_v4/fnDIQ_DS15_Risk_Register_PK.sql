/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Risk Duplicated</title>
  <summary>Is this risk duplicated by risk ID &amp; revision?</summary>
  <message>Count of risk_ID &amp; revision combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150559</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT risk_ID, ISNULL(revision,'') revision
		FROM DS15_risk_register
		WHERE upload_ID = @upload_ID
		GROUP BY risk_ID, ISNULL(revision,'')
		HAVING COUNT(*) > 1
	)
	SELECT 
		R.*
	FROM 
		DS15_risk_register R INNER JOIN Dupes D ON R.risk_ID = D.risk_ID 
												AND ISNULL(R.revision,'') = D.revision
	WHERE 
		upload_ID = @upload_ID
)