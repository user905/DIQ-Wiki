/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subcontract PO &amp; Subcontract ID Combo Misaligned with Subcontract Work Data</title>
  <summary>Is this combo subcontract PO &amp; subcontract ID misaligned with what is in the subcontract data?</summary>
  <message>Combo of subK_PO_ID &amp; subK_ID &lt;&gt; combo of DS13.subK_PO_ID &amp; DS13.subK_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9140539</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_AreSubKAndSubKPOIDComboMisalignedWithDS13] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		C.*
	FROM 
		DS14_HDV_CI C INNER JOIN DS13_subK S ON C.subK_ID = S.subK_ID AND C.subK_PO_ID <> S.subK_PO_ID
	WHERE 
			C.upload_ID = @upload_ID 
		AND S.upload_ID = @upload_ID
)