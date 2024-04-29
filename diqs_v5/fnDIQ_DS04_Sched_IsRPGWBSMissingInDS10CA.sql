/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Reprogramming Missing in CC Log Detail (CA)</title>
  <summary>Is this Work or Planning Planning with reprogramming missing in the CC Log detail?</summary>
  <message>WBS_ID where RPG = Y not found in DS10.WBS_ID list (compare by DS01.parent_WBS_ID where parent is of type CA or SLPP).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040279</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsRPGWBSMissingInDS10CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CCLog as (
		SELECT WBS_ID
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
	), CARPG as (
		SELECT A.Ancestor_WBS_ID CAWBS, S.WBS_ID WPWBS
		FROM DS04_schedule S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE S.upload_ID = @upload_ID AND A.[Type] IN ('PP','SLPP') AND A.Ancestor_Type IN ('CA','SLPP') AND RPG = 'Y'
		GROUP BY A.Ancestor_WBS_ID, S.WBS_ID
	), Flags as (
		SELECT WPWBS
		FROM CARPG RPG LEFT OUTER JOIN CCLog C ON RPG.CAWBS = C.WBS_ID
		WHERE C.WBS_ID IS NULL
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Flags F ON S.WBS_ID = F.WPWBS
	WHERE
		S.upload_ID = @upload_ID
		AND (--return only if there are WADs at the CA level.
				SELECT COUNT(*) 
				FROM DS10_CC_log_detail 
				WHERE upload_ID = @upload_ID 
				AND WBS_ID IN (
					SELECT WBS_ID
					FROM DS01_WBS
					WHERE upload_ID = @upload_ID AND type IN ('CA','SLPP')
				)
		) > 0
)