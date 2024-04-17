/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start Earlier Than Previous Revision</title>
  <summary>Is the POP start of this WAD revision earlier than the POP start of the prior revision?</summary>
  <message>pop_start_date &lt; pop_start_date of prior auth_PM_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080434</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartEarlierThanLastRev] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
WITH LagValues AS (
	SELECT 
		WBS_ID,
		ISNULL(WBS_ID_WP,'') WPWBS,
		auth_PM_date, 
        LAG(pop_start_date) OVER (PARTITION BY WBS_ID, ISNULL(WBS_ID_WP,'') ORDER BY auth_PM_date) AS prevPopStart
  	FROM DS08_WAD
  	WHERE upload_ID = @upload_ID
)
SELECT 
	W.*
FROM 
	DS08_WAD W INNER JOIN LagValues L 	ON W.WBS_ID = L.WBS_ID
										AND ISNULL(W.WBS_ID_WP,'') = L.WPWBS
										AND W.auth_PM_date = L.auth_PM_date
										AND W.POP_start_date < L.prevPopStart
WHERE 
	W.upload_ID = @upload_ID
)