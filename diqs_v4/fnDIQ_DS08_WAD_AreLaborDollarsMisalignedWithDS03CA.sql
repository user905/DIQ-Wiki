/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA Labor Dollars Misaligned With Cost</title>
  <summary>Are the labor budget dollars for this CA WAD misaligned with what is in cost?</summary>
  <message>budget_labor_dollars &lt;&gt; SUM(DS03.BCWSi_dollars) where EOC = labor (by WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080386</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreLaborDollarsMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with LaborCA as (
		SELECT WBS_ID_CA, SUM(BCWSi_dollars) BCWSc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_CA
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN LaborCA C ON W.WBS_ID = C.WBS_ID_CA 
										AND budget_labor_dollars <> C.BCWSc
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)