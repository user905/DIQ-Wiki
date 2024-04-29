/*

The name of the function should include the ID and a short title, for example: DIQ0001_WBS_Pkey or DIQ0003_WBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_WBS" or "FF26_WBS_EU".
DIQ tests might pull data from multiple tables but should only return rows from one table (split up the tests if needed).
This value is the table from which this row returns tests.

status should be set to TEST, LIVE, SKIP.
TEST indicates the test should be run on test/development DIQ checks.
LIVE indicates the test should run on live/production DIQ checks.
SKIP indicates this isn't a test and should be skipped.

severity should be set to WARNING or ERROR. ERROR indicates a blocking check that prevents further data processing.

summary is a summary of the check for a technical audience.

message is the error message displayed to the user for the check.

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
	/*
		This function looks for WBS EU rows where EU_max_dollars < DS03.EAC (by DS03.WBS_ID_CA by EOC).
		It runs only if ACWP is collected at the CA level. If that is not the case,
		there is another function to handle ACWP at the WP level.

		Several steps are needed to do this, with the complicating factor being that ACWP is being 
		collected at the CA level while EU WBS IDs are at the WP level.

		First, create a cte, CostCAEAC, where we get EAC (Sum of ACWPi_Dollars + Sum of ETCi_dollars) 
		by CA WBS ID & EOC.

		Then, in another cte, CAEUWBS, join EU to AncestryTree_Get to get EUMax by CA WBS & EOC.

		A third cte, FlagsByCA, joins these back together and compares the Cost CA EAC to the 
		CA EU Max dollars. 

		Any rows returned are problem CAs.

		A fourth cte, FlagsByWP, joins back to AncestryTree_Get to get the WP WBS IDs that make up 
		those CAs.

		Finally, join back to DS17 to get the problem rows.
	*/

	--Check to see if ACWP is collected at the CA level first.
    WITH CostCAEAC AS (
        --Cost: CA EAC by CA WBS ID & EOC
        SELECT WBS_ID_CA CAWBS, EOC, SUM(ACWPi_dollars) + SUM(ETCi_dollars) EAC
        FROM DS03_cost
        WHERE upload_ID = @upload_ID
        GROUP BY WBS_ID_CA, EOC
    ), CAEUWBS AS (
        --EU: CA EU Max dollars
        SELECT A.Ancestor_WBS_ID CAWBS, E.EOC, SUM(EU_max_dollars) EUMax
        FROM DS17_WBS_EU E INNER JOIN AncestryTree_Get(@upload_ID) A ON E.WBS_ID = A.WBS_ID
        WHERE upload_ID = @upload_ID AND A.[Type] IN ('WP','PP') AND A.Ancestor_WBS_ID = 'CA'
        GROUP BY A.Ancestor_WBS_ID, E.EOC
    ), FlagsByCA AS (
        --Problem CAs
        SELECT EU.CAWBS, EU.EOC
        FROM CAEUWBS EU INNER JOIN CostCAEAC C ON EU.CAWBS = C.CAWBS AND EU.EOC = C.EOC
        WHERE EU.EUMax < C.EAC
    ), FlagsByWP AS (
        --WP's making up the problem CAs
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