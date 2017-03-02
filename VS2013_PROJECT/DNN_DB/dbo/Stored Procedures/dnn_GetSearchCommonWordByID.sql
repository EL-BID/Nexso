CREATE PROCEDURE [dbo].[dnn_GetSearchCommonWordByID]
	@CommonWordID int
	
AS

SELECT
	[CommonWordID],
	[CommonWord],
	[Locale]
FROM
	dbo.dnn_SearchCommonWords
WHERE
	[CommonWordID] = @CommonWordID

