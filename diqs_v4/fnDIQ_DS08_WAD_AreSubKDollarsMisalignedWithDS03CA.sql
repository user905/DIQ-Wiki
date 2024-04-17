/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA Subcontract Dollars Misaligned With Cost</title>
  <summary>Are the subcontract budget dollars for this CA WAD misaligned with what is in cost?</summary>
  <message>budget_subcontract_dollars &lt;&gt; SUM(DS03.BCWSi_dollars) where EOC = subcontract (by WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080396</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreSubKDollarsMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SubcontractCA as (
		SELECT WBS_ID_CA, SUM(BCWSi_dollars) BCWSc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract'
		GROUP BY WBS_ID_CA
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN SubcontractCA C 	ON W.WBS_ID = C.WBS_ID_CA
												AND budget_subcontract_dollars <> C.BCWSc
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)