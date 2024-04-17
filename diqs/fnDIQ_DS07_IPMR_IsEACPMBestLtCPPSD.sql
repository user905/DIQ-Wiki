/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM EAC Best Date Earlier Than CPP SD</title>
  <summary>Is the PM EAC Best date earlier than the CPP Status Date?</summary>
  <message>EAC_PM_best_date &lt; DS00.CPP_Status_Date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070264</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMBestLtCPPSD] (
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
		AND EAC_PM_best_date < CPP_status_date
)