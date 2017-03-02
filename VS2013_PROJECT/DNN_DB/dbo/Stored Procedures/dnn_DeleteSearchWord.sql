CREATE PROCEDURE [dbo].[dnn_DeleteSearchWord]
	@SearchWordsID int
AS

DELETE FROM dbo.dnn_SearchWord
WHERE
	[SearchWordsID] = @SearchWordsID

