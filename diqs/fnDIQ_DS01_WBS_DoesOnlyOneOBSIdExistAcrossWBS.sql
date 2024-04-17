/*
<documentation>
  <author>Elias Cooper</author>
  <id>16</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Single OBS Across WBS Hierarchy</title>
  <summary>Was more than one unique OBS_ID used across the WBS?</summary>
  <message>Only a single OBS_ID found for all WBS Elements; more than one OBS ID is required across the WBS hierarchy</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1010006</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesOnlyOneOBSIdExistAcrossWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    SELECT	
        *
    FROM	
        DummyRow_Get(@upload_id)
    WHERE (SELECT COUNT(DISTINCT OBS_ID) FROM DS01_WBS WHERE upload_ID = @upload_id AND TRIM(ISNULL(OBS_ID, '')) <> '') = 1
)