/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Indirect With Hours</title>
  <summary>Does this indirect resource have hours?</summary>
  <message>budget, actual, or remaining units &gt; 0 where EOC = Indirect.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060267</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_DoesIndirectHaveUnits] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT *
	FROM DS06_schedule_resources 
	WHERE upload_id = @upload_ID 
		AND EOC = 'Indirect'
		AND (budget_units > 0 OR actual_units > 0 OR remaining_units > 0)
)