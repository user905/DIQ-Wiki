/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP Labor Dollars Misaligned With Cost</title>
  <summary>Are the labor budget dollars for this WP/PP WAD misaligned with what is in cost?</summary>
  <message>budget_labor_dollars &lt;&gt; SUM(DS03.BCWSi_dollars) where EOC = labor (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080387</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreLaborDollarsMisalignedWithDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with LaborWP as (
		SELECT WBS_ID_WP, SUM(BCWSi_dollars) BCWSc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN LaborWP C ON W.WBS_ID_WP = C.WBS_ID_WP 
										AND budget_labor_dollars <> C.BCWSc
	WHERE
		upload_ID = @upload_ID  
)