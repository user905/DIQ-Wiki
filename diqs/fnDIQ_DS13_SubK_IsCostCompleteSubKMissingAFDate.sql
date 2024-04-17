/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Complete Subcontract Missing Actual Finish</title>
  <summary>Is this 100% complete subcontract missing an actual finish date?</summary>
  <message>BCWPc_dollars / BAC_dollars = 1 &amp; AF_date missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1130527</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsCostCompleteSubKMissingAFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS13_subK
	WHERE 
			upload_ID = @upload_ID 
		AND BCWPc_dollars / NULLIF(BAC_dollars,0) = 1
		AND AF_date IS NULL
)