/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>EAC &gt; BAC without OTB / OTS Date</title>
  <summary>Is EAC greater than BAC without an OTB / OTS date?</summary>
  <message>DS03.ACWPc + DS03.ETCc &gt; DS03.BCWSc &amp; OTB_OTS_date is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070364</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACGtBACWithoutOTBOTSDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with UBEst as  (
		SELECT ISNULL(UB_est_dollars,0) UBEst
		FROM DS07_IPMR_header
		WHERE upload_ID = @upload_ID
	), UBBgt as (
		SELECT ISNULL(UB_bgt_dollars,0) UBBgt
		FROM DS07_IPMR_header
		WHERE upload_ID = @upload_ID
	), EAC as (
		SELECT SUM(ISNULL(ETCi_dollars,0) + ISNULL(ACWPi_dollars,0)) + (SELECT TOP 1 UBEst FROM UBest) EAC
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID 
	), BAC as (
		SELECT SUM(ISNULL(BCWSi_dollars,0)) + (SELECT TOP 1 UBBgt FROM UBBgt) BAC
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID 
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (SELECT TOP 1 EAC FROM EAC) > (SELECT TOP 1 BAC FROM BAC)
		AND OTB_OTS_date IS NULL
)