/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP Indirect Dollars Misaligned With Cost</title>
  <summary>Are the indirect budget dollars for this WP/PP WAD misaligned with what is in cost?</summary>
  <message>budget_indirect_dollars &lt;&gt; SUM(DS03.BCWSi_dollars) where EOC = Indirect or is_indirect = Y (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080410</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreIndirectDollarsMisalignedWithDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with IndirectWP as (
		SELECT WBS_ID_WP, SUM(BCWSi_dollars) BCWSc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (EOC = 'Indirect' or is_indirect = 'Y') AND WBS_ID_WP IS NOT NULL
		GROUP BY WBS_ID_WP
	)
	SELECT 
		W.*
	FROM 
		DS08_WAD W INNER JOIN IndirectWP C 	ON W.WBS_ID_WP = C.WBS_ID_WP
											AND budget_indirect_dollars <> C.BCWSc
	WHERE
		upload_ID = @upload_ID  
)