/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>OTB/OTS Transactions Misaligned with Cost (CA)</title>
  <summary>Do the OTB/OTS transaction dollars for this Control Account sum to something other than the BAC reprogramming in cost?</summary>
  <message>Sum of dollars_delta where category = OTB, OTS, or OTB-OTS &lt;&gt; Sum of DS03.BAC_rpg (by WBS_ID_CA).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100469</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsOTBOTSRpgMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Flags as (
		SELECT CCDB.WBS_ID
		FROM ( --cost BAC_Rpg by CA BWS
				SELECT 
					WBS_ID_CA, SUM(BAC_rpg) BAC_Rpg
				FROM DS03_cost
				WHERE upload_ID = @upload_ID
				GROUP BY WBS_ID_CA
			) CostDB INNER JOIN (
				SELECT WBS_ID, SUM(dollars_delta) Rpg
				FROM DS10_CC_log_detail
				WHERE upload_ID = @upload_ID AND category IN ('OTB', 'OTS','OTB-OTS')
				GROUP BY WBS_ID
			) CCDB ON CostDB.WBS_ID_CA = CCDB.WBS_ID
		WHERE
			CostDB.BAC_Rpg <> CCDB.Rpg
	)
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND category IN ('OTB', 'OTS','OTB-OTS')
	AND WBS_ID IN (
		SELECT WBS_ID FROM Flags
	)
)