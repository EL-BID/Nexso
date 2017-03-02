CREATE PROCEDURE [dbo].[dnn_DeleteSearchStopWords]
	@StopWordsID int
AS
BEGIN	
	DELETE FROM dbo.dnn_SearchStopWords WHERE StopWordsID = @StopWordsID
END

