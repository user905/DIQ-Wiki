/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>DB Dollar Transactions Misaligned with Cost (WP)</title>
  <summary>Do the DB transaction dollars for this Work Package sum to something other than the DB in cost?</summary>
  <message>Sum of dollars_delta where category = DB &lt;&gt; Sum of DS03.BCWSi_dollars (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100454</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreDBDollarsMisalignedWithDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Flags as (
		SELECT CCDB.WBS_ID
		FROM ( --cost DB by WP BWS
				SELECT 
					WBS_ID_WP, SUM(BCWSi_dollars) DB
				FROM DS03_cost
				WHERE upload_ID = @upload_ID
				GROUP BY WBS_ID_WP
			) CostDB INNER JOIN (
				SELECT WBS_ID, SUM(dollars_delta) DB
				FROM DS10_CC_log_detail
				WHERE upload_ID = @upload_ID AND category = 'DB'
				GROUP BY WBS_ID
			) CCDB ON CostDB.WBS_ID_WP = CCDB.WBS_ID
		WHERE
			CostDB.DB <> CCDB.DB
	)
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND category = 'DB'
	AND WBS_ID IN (
		SELECT WBS_ID FROM Flags
	)
)