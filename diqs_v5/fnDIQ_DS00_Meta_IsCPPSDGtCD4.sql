/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS00 Metadata</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <type>Internal</type>
  <title>CPP Status Date Is After CD-4</title>
  <summary>Is the CPP Status Date after CD-4?</summary>
  <message>DS00.CPP_Status_Date &gt; min DS04.ES_date or EF_date where milestone_level = 190.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1000002</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS00_Meta_IsCPPSDGtCD4] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN 
(
	with CD4 as (
		SELECT cpp_status_date, COALESCE(MIN(ES_date), MIN(EF_date)) CD4Date
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 190
		GROUP BY CPP_status_date
	)
	SELECT
		*
	FROM
		DummyRow_Get(@upload_ID)
	WHERE (SELECT COUNT(*) FROM CD4 WHERE cpp_status_date > CD4Date) > 0
)