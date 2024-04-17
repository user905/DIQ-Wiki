/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA with CA Child</title>
  <summary>Does the CA have a CA as a child in the WBS hierarchy?</summary>
  <message>CA found with child of type CA in the WBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010003</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesCAHaveACAChild] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with WBS as (
      SELECT * 
      FROM DS01_WBS 
      WHERE upload_ID = @upload_ID and type = 'CA'
  )
	SELECT 
		Parent.*
	FROM
		(SELECT parent_WBS_ID FROM WBS) as Child INNER JOIN (SELECT * FROM WBS) as Parent ON Child.parent_WBS_ID = Parent.WBS_ID
)