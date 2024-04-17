/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Single CAM Across WBS Hierarchy</title>
  <summary>Was only one unique CAM used across the WBS?</summary>
  <message>Only a single CAM found for all WBS Elements; more than one CAM is required across the WBS hierarchy</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010005</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesOnlyOneCAMExistAcrossWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    SELECT 
        *
    FROM
        DummyRow_Get(@upload_id)
    WHERE (SELECT COUNT(DISTINCT CAM) FROM DS01_WBS	WHERE upload_ID = @upload_id AND TRIM(ISNULL(CAM,'')) <> '') = 1
)