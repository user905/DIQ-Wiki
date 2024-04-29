/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Non-Unique Cost Row</title>
  <summary>Is this row duplicated by period date, CA WBS ID, WP WBS ID, EOC, EVT, &amp; is_indirect?</summary>
  <message>Count of period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT, is_indirect combo &gt; 1.</message>
  <grouping>period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT, is_indirect</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030108</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT period_date, WBS_ID_CA, ISNULL(WBS_ID_WP,'') WBS_ID_WP, EOC, ISNULL(EVT,'') EVT, ISNULL(is_indirect,'') IsInd
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY period_date, WBS_ID_CA, ISNULL(WBS_ID_WP,''), EOC, ISNULL(EVT,''), ISNULL(is_indirect,'')
		HAVING COUNT(*) > 1
	)
	SELECT C.* 
	FROM DS03_Cost C INNER JOIN Dupes D ON C.period_date = D.period_date 
										AND C.WBS_ID_CA = D.WBS_ID_CA 
										AND ISNULL(C.WBS_ID_WP,'') = D.WBS_ID_WP 
										AND C.EOC = D.EOC 
										AND ISNULL(C.EVT,'') = D.EVT
										AND ISNULL(C.is_indirect,'') = D.IsInd
	WHERE upload_ID = @upload_ID
)