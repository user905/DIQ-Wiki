/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>WP or PP Found Across Multiple CAs</title>
  <summary>Is the WP or PP found across multiple Control Accounts?</summary>
  <message>WBS_ID_WP found across distinct WBS_ID_CA.</message>
  <grouping>WBS_ID_CA,WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030106</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPorPPRepeatedAcrossCAs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with RepeatWPs as (
		SELECT C1.WBS_ID_CA, C1.WBS_ID_WP
		FROM DS03_cost C1 INNER JOIN DS03_cost C2 ON C1.WBS_ID_WP = C2.WBS_ID_WP 
												AND C1.WBS_ID_CA <> C2.WBS_ID_CA
		WHERE 	TRIM(ISNULL(C1.WBS_ID_WP,'')) <> ''
			AND C1.upload_id = @upload_ID
			AND C2.upload_ID = @upload_ID
		group by 
			C1.WBS_ID_WP, C1.WBS_ID_CA
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN RepeatWPs R 	ON R.WBS_ID_CA = C.WBS_ID_CA
											AND R.WBS_ID_WP = C.WBS_ID_WP
	WHERE 
		C.upload_ID = @upload_ID
)