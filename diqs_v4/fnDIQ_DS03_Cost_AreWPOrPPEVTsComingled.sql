/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>WP or PP with Multiple EVT Groups</title>
  <summary>Does this WP or PP have more than one EVT group?</summary>
  <message>WP or PP where EVT group is not uniform (EVTs are not all LOE, Discrete, Apportioned, or Planning Package for this WP or PP data).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030072</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreWPOrPPEVTsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with EVTGroups as (
		SELECT 
			WBS_ID_WP, 
			CASE
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
				WHEN EVT = 'K' THEN 'PP'
				ELSE ''
			END as EVT
		FROM
			DS03_cost
		WHERE
			upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND TRIM(ISNULL(EVT,'')) <> ''
	), Flags AS (
		SELECT G1.WBS_ID_WP
		FROM EVTGroups G1 INNER JOIN EVTGroups G2 	ON G1.WBS_ID_WP = G2.WBS_ID_WP
													AND G1.EVT <> G2.EVT
		GROUP BY G1.WBS_ID_WP
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_WP = F.WBS_ID_WP 
	WHERE
		upload_ID = @upload_ID
)