/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Max Dollars Less Than EAC (CA)</title>
  <summary>Are the EU maximum dollars less than the cost EAC (at the CA level)?</summary>
  <message>EU_max_dollars &lt; DS03.EAC by WBS_ID_CA &amp; EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170577</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsEUMaxLtDS03EACCA] (
    @upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    WITH CostCAEAC AS (
        SELECT WBS_ID_CA CAWBS, EOC, SUM(ACWPi_dollars) + SUM(ETCi_dollars) EAC
        FROM DS03_cost
        WHERE upload_ID = @upload_ID
        GROUP BY WBS_ID_CA, EOC
    ), CAEUWBS AS (
        SELECT A.Ancestor_WBS_ID CAWBS, E.EOC, SUM(EU_max_dollars) EUMax
        FROM DS17_WBS_EU E INNER JOIN AncestryTree_Get(@upload_ID) A ON E.WBS_ID = A.WBS_ID
        WHERE upload_ID = @upload_ID AND A.[Type] IN ('WP','PP') AND A.Ancestor_WBS_ID = 'CA'
        GROUP BY A.Ancestor_WBS_ID, E.EOC
    ), FlagsByCA AS (
        SELECT EU.CAWBS, EU.EOC
        FROM CAEUWBS EU INNER JOIN CostCAEAC C ON EU.CAWBS = C.CAWBS AND EU.EOC = C.EOC
        WHERE EU.EUMax < C.EAC
    ), FlagsByWP AS (
        SELECT A.WBS_ID, F.EOC
        FROM FlagsByCA F INNER JOIN AncestryTree_Get(@upload_ID) A ON F.CAWBS = A.Ancestor_WBS_ID
        WHERE A.[Type] IN ('WP','PP') AND A.Ancestor_WBS_ID = 'CA'
    )
    SELECT 
        E.*
    FROM 
        DS17_WBS_EU E INNER JOIN FlagsByWP F ON E.WBS_ID = F.WBS_ID AND E.EOC = F.EOC
    WHERE 
        	upload_ID = @upload_ID
        AND EXISTS ( --run only if ACWP is collected at the CA level
			SELECT 1 
			FROM DS03_cost 
			WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = '' AND ACWPi_Dollars > 0
		)
)