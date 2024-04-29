/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CC Found Without CC Description</title>
  <summary>Is there are CC without an accompanying description?</summary>
  <message>CC ID found without an accompanying CC description</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030063</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesCCExistWithoutCCDescription] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		  * 
	FROM 
		DS03_Cost
	WHERE 
			  upload_ID = @upload_ID
		AND TRIM(ISNULL(CC_ID,'')) <> ''
		AND TRIM(ISNULL(CC_description,'')) = ''
)