/*
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
			EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND IsInd = 'Y' AND EOC = 'Indirect' AND HasA = 1)
		AND EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = 'Y' AND EOC <> 'Indirect' AND HasA = 1)
	) OR (
			EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND IsInd = 'Y' AND EOC = 'Indirect' AND HasA = 1)
		AND EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND IsInd = 'Y' AND EOC = 'Indirect' AND HasA = 0)
	) OR (	--WP/CAs where IsInd = N & EOC = Indirect (bit of an outlier, but still needed for quality)
			EXISTS (SELECT 1 FROM Cost WHERE IsInd = 'N' AND EOC = 'Indirect')
	) OR ( -- EOC = Indirect at both CA & WP levels
			EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND EOC = 'Indirect' AND HasA = 1)
		AND EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND EOC = 'Indirect' AND HasA = 1)
	) OR (	--Scenario F.a and any other scenario
			EXISTS (SELECT 1 FROM Cost WHERE CA = WP)
		AND EXISTS (SELECT 1 FROM Cost WHERE CA <> WP)
	) OR ( -- Also scenario F.a and any other scenario
			EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = 'Y' AND EOC = 'Indirect' AND HasA = 1)
		AND EXISTS (SELECT 1 FROM Cost WHERE WP <> '' AND IsInd = 'Y' AND EOC <> 'Indirect' AND HasA = 1)
	)
)