/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>WP Overhead Dollars Misaligned With Cost</title>
  <summary>Are the overhead budget dollars for this WP/PP WAD misaligned with what is in cost?</summary>
  <message>budget_overhead_dollars &lt;&gt; SUM(DS03.BCWSi_dollars) where EOC = overhead (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080395</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreOverheadDollarsMisalignedWithDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with OverheadWP as (
		SELECT WBS_ID_WP, SUM(BCWSi_dollars) BCWSc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Overhead'
		GROUP BY WBS_ID_WP
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN OverheadWP C 	ON W.WBS_ID_WP = C.WBS_ID_WP
											AND budget_indirect_dollars <> C.BCWSc
	WHERE
		upload_ID = @upload_ID  
)