/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Labor Found Alongside Non-Indirect EOC</title>
  <summary>Does this WP/PP mingle Labor with other EOC types (excluding Indirect)?</summary>
  <message>EOC = Labor &amp; Material, Subcontract, or ODC by WBS_ID_WP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030117</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborComingledWithNonIndirectEOCs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonLbr AS (
		SELECT WBS_ID_WP WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC NOT IN ('Labor','Indirect') AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	)
	SELECT C.* 
	FROM DS03_Cost C LEFT OUTER JOIN NonLbr N ON C.WBS_ID_WP = N.WPID
	WHERE	upload_ID = @upload_ID AND EOC = 'Labor' AND N.WPID IS NOT NULL
)