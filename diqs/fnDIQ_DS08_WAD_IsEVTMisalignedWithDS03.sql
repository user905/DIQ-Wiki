/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EVT Misaligned with Cost</title>
  <summary>Is the EVT for this WP/PP-level WAD misaligned with what is in cost?</summary>
  <message>EVT &lt;&gt; DS03.EVT (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080409</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsEVTMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostEVT as (
		SELECT WBS_ID_WP, EVT
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EVT
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN CostEVT C ON W.WBS_ID_WP = C.WBS_ID_WP
										AND W.EVT <> C.EVT
	WHERE
			W.upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)