/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-LOE Time Dependence</title>
  <summary>Is this time dependent WBS non-LOE in cost?</summary>
  <message>time_dependent = Y &amp; DS03.EVT &lt;&gt; A (by WBS_ID).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170581</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsTimeDepNonLOE] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostLOE as (
		SELECT WBS_ID_WP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EVT = 'A'
		GROUP BY WBS_ID_WP
	)
	SELECT 
		E.*
	FROM 
		DS17_WBS_EU E LEFT OUTER JOIN CostLOE C ON E.WBS_ID = C.WBS_ID_WP
	WHERE 
			upload_ID = @upload_ID
		AND time_dependent = 'Y'
		AND TRIM(ISNULL(C.WBS_ID_WP,'')) = ''
)