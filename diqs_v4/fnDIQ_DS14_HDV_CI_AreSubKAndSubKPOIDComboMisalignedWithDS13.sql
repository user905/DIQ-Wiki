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
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subcontract PO &amp; Subcontract ID Combo Misaligned with Subcontract Work Data</title>
  <summary>Is this combo subcontract PO &amp; subcontract ID misaligned with what is in the subcontract data?</summary>
  <message>Combo of subK_PO_ID &amp; subK_ID &lt;&gt; combo of DS13.subK_PO_ID &amp; DS13.subK_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9140539</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_AreSubKAndSubKPOIDComboMisalignedWithDS13] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This function looks for rows where combo of subK_ID & subK_PO_ID <> combo of DS13 subK_ID & subK_PO_ID
	*/
	SELECT 
		C.*
	FROM 
		DS14_HDV_CI C INNER JOIN DS13_subK S ON C.subK_ID = S.subK_ID AND C.subK_PO_ID <> S.subK_PO_ID
	WHERE 
			C.upload_ID = @upload_ID 
		AND S.upload_ID = @upload_ID

)