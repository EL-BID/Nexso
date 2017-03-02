CREATE PROCEDURE [dbo].[dnn_DeleteSearchCommonWord]
	@CommonWordID int
AS

DELETE FROM dbo.dnn_SearchCommonWords
WHERE
	[CommonWordID] = @CommonWordID

