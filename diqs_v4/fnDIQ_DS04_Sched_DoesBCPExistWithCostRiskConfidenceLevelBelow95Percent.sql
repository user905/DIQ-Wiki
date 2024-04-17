/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Quantitative Risk Analysis Confidence Level for Cost Below 95% Following BCP</title>
  <summary>Is the quantitative risk analysis confidence level for cost below 95% following a BCP?</summary>
  <message>BCP found (milestone_level = 131 - 135) with quantitative risk analysis confidence level for cost below 95% (DS07.QRA_CL_cost_pct).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040116</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesBCPExistWithCostRiskConfidenceLevelBelow95Percent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with QRACL as (
		SELECT ISNULL(QRA_CL_cost_pct,0) QRACL 
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND milestone_level BETWEEN 131 AND 135
		AND (SELECT QRACL FROM QRACL) < .95
)