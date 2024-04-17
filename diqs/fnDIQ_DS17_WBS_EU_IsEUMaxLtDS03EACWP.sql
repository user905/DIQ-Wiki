/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Max Dollars Less Than EAC (WP)</title>
  <summary>Are the EU maximum dollars less than the cost EAC for this WBS / EOC combo?</summary>
  <message>EU_max_dollars &lt; DS03.EAC by WBS_ID_WP &amp; EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170578</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsEUMaxLtDS03EACWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWPEAC as (
		SELECT WBS_ID_WP, EOC, SUM(ACWPi_dollars) + SUM(ETCi_dollars) EAC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
	)
	SELECT 
		E.*
	FROM 
		DS17_WBS_EU E INNER JOIN CostWPEAC C ON E.WBS_ID = C.WBS_ID_WP AND E.EOC = C.EOC
	WHERE 
			upload_ID = @upload_ID
		AND E.EU_max_dollars < C.EAC
)