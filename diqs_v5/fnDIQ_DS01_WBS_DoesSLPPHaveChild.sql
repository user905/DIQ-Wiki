/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SLPP with Child</title>
  <summary>Does the SLPP have a child in the WBS hierarchy?</summary>
  <message>SLPP found with child in the WBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010007</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesSLPPHaveChild] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		Parent.*
	FROM
		(SELECT parent_WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID) as Child, -- children
		(SELECT * FROM DS01_WBS WHERE upload_ID = @upload_ID AND type = 'SLPP') as Parent -- parents of type SLPP
	WHERE
		Child.parent_WBS_ID = Parent.WBS_ID
)