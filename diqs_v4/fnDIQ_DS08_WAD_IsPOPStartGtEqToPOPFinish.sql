/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>POP Start On or After POP Finish</title>
  <summary>Is the POP start on or after the POP finish?</summary>
  <message>pop_start_date &gt;= pop_finish_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080435</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartGtEqToPOPFinish] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
SELECT 
	*
FROM 
	DS08_WAD
WHERE 
		upload_ID = @upload_ID
	AND POP_start_date >= POP_finish_date
)