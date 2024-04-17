/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>LOE Mingled With Other EVT Types</title>
  <summary>Is LOE mingled with other EVT types for this WBS?</summary>
  <message>LOE (EVT = LOE) is mingled with other EVT types (EVT &lt;&gt; LOE) for this WBS_ID.</message>
  <grouping>WBS_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040186</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreEVTsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with EVTGroups as (
		SELECT 
			WBS_ID, 
			schedule_type,
			CASE
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
				WHEN EVT = 'K' THEN 'PP'
			END as EVT
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(EVT, '')) <> ''
	), Flags AS (
		SELECT G1.WBS_ID, G1.schedule_type
		FROM EVTGroups G1 INNER JOIN EVTGroups G2 	ON G1.WBS_ID = G2.WBS_ID 
													AND G1.schedule_type = G2.schedule_type
													AND G1.EVT <> G2.EVT
		WHERE G1.EVT <> '' AND G2.EVT <> ''
		GROUP BY G1.WBS_ID, G1.schedule_type
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Flags F ON S.WBS_ID = F.WBS_ID AND S.schedule_type = F.schedule_type
	WHERE
		upload_id = @upload_ID
)