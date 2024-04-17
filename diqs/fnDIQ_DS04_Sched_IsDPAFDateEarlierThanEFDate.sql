/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Actual Finish Prior to Early Finish Along the Driving Path</title>
  <summary>Does this FC task along the Driving Path have an Actual Finish earlier than the BL Early Finish?</summary>
  <message>FC AF_date &lt; BL EF_date where driving_path = Y (compare by task_ID &amp; subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040166</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDPAFDateEarlierThanEFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BLDPTask as (
		SELECT task_ID, EF_Date, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND driving_path = 'Y'
	)
	SELECT
		F.*
	FROM
		DS04_schedule F INNER JOIN BLDPTask B ON F.task_ID = B.task_ID
											 AND ISNULL(F.subproject_ID,'') = B.SubP
											 AND F.AF_date < B.EF_date
	WHERE
			F.upload_id = @upload_ID
		AND F.schedule_type = 'FC'
)