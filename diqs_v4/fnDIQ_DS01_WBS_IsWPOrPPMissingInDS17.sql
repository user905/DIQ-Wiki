/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WP or PP Missing EU</title>
  <summary>Is this WP or PP missing in the WBS EU log?</summary>
  <message>WBS_ID not in DS17.WBS_ID list where DS01.type = WP or PP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010001</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWPOrPPMissingInDS17] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WBSEU as (
		SELECT WBS_ID
		FROM DS17_WBS_EU
		WHERE upload_ID = @upload_ID
	), BLTasks as (
		SELECT WBS_ID, ISNULL(subtype,'') Subtype
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
		GROUP BY WBS_ID, subtype
	), SVTWBSs as (
		SELECT WBS_ID
		FROM BLTasks
		GROUP BY WBS_ID
		HAVING MIN(Subtype) = MAX(Subtype) AND MIN(Subtype) = 'SVT'
	)
	SELECT 
		* 
	FROM 
		DS01_WBS
	WHERE 
			upload_ID = @upload_ID
		AND type in ('PP','WP')
		AND WBS_ID NOT IN (SELECT WBS_ID FROM WBSEU)
		AND WBS_ID NOT IN (SELECT WBS_ID FROM SVTWBSs) --ignore SVT WBSs
		AND (SELECT COUNT(*) FROM WBSEU) > 0 -- run only if DS17 has data
)