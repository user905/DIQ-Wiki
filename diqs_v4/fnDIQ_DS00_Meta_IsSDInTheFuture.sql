/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS00 Metadata</table>
  <status>DELETED</status>
  <severity>ERROR</severity>
  <title>Future CPP Status Date</title>
  <summary>Is the CPP Status Date in the future?</summary>
  <message>DS00.CPP_Status_Date &gt; today's date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1000003</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS00_Meta_IsSDInTheFuture] (
	@upload_id int = 0
)
RETURNS  @dummy table ( upload_id int )
AS
BEGIN
	IF((SELECT TOP 1 CPP_status_date FROM DS01_WBS WHERE upload_ID = @upload_ID) > GETDATE())
	BEGIN
		INSERT INTO @dummy
		SELECT 
			*
		FROM 
			DummyRow_Get(@upload_ID)
	END
	RETURN
END