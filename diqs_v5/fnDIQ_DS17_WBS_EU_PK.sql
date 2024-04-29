/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Estimate Uncertainty Entry</title>
  <summary>Is this WBS / EOC combo duplicated?</summary>
  <message>Count of combo WBS &amp; EOC combo &gt; 1.</message>
  <grouping>WBS_ID,EOC</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1170582</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT WBS_ID ,EOC
		FROM DS17_WBS_EU
		WHERE upload_id = @upload_ID
		GROUP BY WBS_ID, EOC
		HAVING COUNT(*) > 1
	)
	SELECT 
		E.*
	FROM 
		DS17_WBS_EU E INNER JOIN Dupes D ON E.WBS_ID = D.WBS_ID 
										AND E.EOC = D.EOC
	WHERE 
		upload_ID = @upload_ID
)