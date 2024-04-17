/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Reprogramming Without OTB/OTS Date</title>
  <summary>Is there BAC, CV, or SV repgrogramming but not OTB/OTS Date?</summary>
  <message>BAC_rpg, CV_rpg, or SV_rpg &lt;&gt; 0 but without OTB_OTS_Date in DS07 (IPMR Header).</message>
  <grouping>PARSID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030070</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesRPGExistWithoutDS07OTBOTSDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    SELECT	*
    FROM	DS03_Cost
    WHERE	upload_ID = @upload_id
			AND (BAC_rpg <> 0 OR CV_rpg <> 0 OR SV_rpg <> 0)
			AND EXISTS(
				SELECT	*
				FROM	DS07_IPMR_header
				WHERE	upload_ID = @upload_id
						AND OTB_OTS_Date IS NULL
			)
)