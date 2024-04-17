/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>OTB or OTS Transaction Dollars Without OTB-OTS Date</title>
  <summary>Are there OTB/OTS transactions when no OTB/OTS date exists?</summary>
  <message>Sum of dollars_delta where category = OTB, OTS, or OTB-OTS &lt;&gt; 0 &amp; DS07.OTB_OTS_date is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100460</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_DoOTBOTSDollarsExistWithoutDS07OTBOTSDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	 SELECT 
        *
    FROM 
        DS10_CC_log_detail
    WHERE 
        upload_ID = @upload_id
        AND category IN ('OTB', 'OTS', 'OTB-OTS')
        AND EXISTS (
            SELECT 1 
            FROM DS07_IPMR_header
            WHERE upload_ID = @upload_id AND OTB_OTS_date IS NULL
        )
		AND EXISTS (
			SELECT 1
			FROM DS10_CC_log_detail
			WHERE upload_ID = @upload_id
				AND category IN ('OTB', 'OTS', 'OTB-OTS')
				AND dollars_delta <> 0
		)
)