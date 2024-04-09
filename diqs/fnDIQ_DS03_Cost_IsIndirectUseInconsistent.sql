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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Inconsistent Use of Indirect</title>
  <summary>Is indirect distributed inconsistently?</summary>
  <message>Possible Reasons: 1) indirect actuals found where is_indirect = Y, and both EOC = Indirect and EOC &lt;&gt; Indirect are used; 2) is_indirect utilized in some WPs/CAs and missing in others; 3) indirect actuals found at both the CA &amp; WP levels; 4) data found where is_indirect = N but EOC = Indirect.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1030116</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectUseInconsistent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This DIQ looks to see whether use of indirect is consistent. 
		For example, if they use indirect like the below, then all data should look like the below, 
		i.e. there should be no EOC = Indirect, no indirect at the CA level, etc.
		WBS_ID_CA	WBS_ID_WP	is_indirect	EOC		EVT	BCWSi		BWCPi		ACWPi		ETCi
		01.01.01	01.01.01.01	N			labor	C	$direct 	$direct		$direct		$direct
		01.01.01	01.01.01.01	Y			labor	C	$indirect	$indirect	$indirect	$indirect
	*/
	with Cost as (
		SELECT WBS_ID_CA CA, ISNULL(WBS_ID_WP,'') WP, ISNULL(is_indirect,'') IsInd, EOC, CASE WHEN ACWPi_Dollars > 0 OR ACWPi_hours > 0 OR ACWPi_FTEs > 0 THEN 1 ELSE 0 END HasA
		FROM DS03_cost
		WHERE upload_ID = @upload_id
	)
	
	SELECT *
	FROM DummyRow_Get(@upload_ID)
	WHERE  	( --WP Indirect Actuals where IsInd = Y, and where both EOC = Indirect and EOC <> Indirect are used.
			EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = 'Y' AND EOC = 'Indirect' AND HasA = 1) 
		AND EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = 'Y' AND EOC <> 'Indirect' AND HasA = 1)
	) OR (	--WP actuals where IsInd is utilized and where it is not (i.e. if it is used, it must be used everywhere, and vice versa)
			EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = '' AND HasA = 1) 
		AND EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd <> '' AND HasA = 1) 
	) OR ( 	--CA Indirect Actuals collected where EOC = Indirect AND IsInd = Y, while WP Indirect Actuals collected where EOC <> Indirect AND IsInd = Y
			--This covers the scenario where Actuals are collected at both CA & WP levels. 
			--The one exception is that direct actuals may be collected at the WP level (where EOC <> Indirect and IsInd = N) 
			--while indirect actuals are collected at the CA level (where EOC = Indirect and IsInd = Y).
			--The below excludes the exception.
			EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND IsInd = 'Y' AND EOC = 'Indirect' AND HasA = 1)
		AND EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = 'Y' AND EOC <> 'Indirect' AND HasA