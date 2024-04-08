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

	/*
		Checks to see if EAC > BAC when no OTB OTS date exists
		Note: EAC = DS03.ACWPc + DS03.ETCc + DS07.UB_est_dollars
		Note: BAC = DS03.BCWSc + DS07.UB_bgt_dollars
	*/

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