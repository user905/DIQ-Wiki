/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SS or FF Improperly Linked With Other Relationship Types</title>
  <summary>Does this SS or FF relationship exist alongside an FS or SF relationship?</summary>
  <message>Predecessor has at least one SS or FF relationship (type = SS or FF) and one non-SS or non-FF relationship tied to it (type = SF or FS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1050234</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsSSorFFRelTypeImproperlyLinked] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Flags as (
		SELECT schedule_type, predecessor_task_ID, ISNULL(predecessor_subproject_ID,'') PSubP, STRING_AGG(type, ',') WITHIN GROUP (ORDER BY type) Type
		FROM DS05_schedule_logic
		WHERE upload_ID = @upload_ID
		GROUP BY schedule_type, predecessor_task_ID, ISNULL(predecessor_subproject_ID,'')
	)
	SELECT L.*
	FROM DS05_schedule_logic L INNER JOIN Flags F 	ON L.schedule_type = F.schedule_type
													AND L.predecessor_task_ID = F.predecessor_task_ID
													AND ISNULL(L.predecessor_subproject_ID,'') = F.PSubP
	WHERE upload_ID = @upload_ID
		AND (
				F.[Type] LIKE '%SS%FS%'
			OR	F.[Type] LIKE '%FS%SS%'
			OR	F.[Type] LIKE '%SS%SF%'
			OR	F.[Type] LIKE '%SF%SS%'
			OR 	F.[Type] LIKE '%FF%FS%'
			OR 	F.[Type] LIKE '%FS%FF%'
			OR 	F.[Type] LIKE '%FF%SF%'
			OR 	F.[Type] LIKE '%SF%FF%'
		)
)