/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>POP Start After Schedule Actual Start (WP)</title>
  <summary>Is the POP start for this Work Package WAD after the actual start in the forecast schedule?</summary>
  <message>pop_start &gt; DS04.AS_date where schedule_type = FC (by DS08.WBS_ID_WP &amp; DS04.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080617</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS04ASDateWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPActS as (
		SELECT WBS_ID WBS, MAX(AS_date) ActS
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
		GROUP BY WBS_ID
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN WPActS A 	ON W.WBS_ID_WP = A.WBS	
										AND W.POP_start_date > A.ActS
	WHERE
		upload_ID = @upload_ID  
)