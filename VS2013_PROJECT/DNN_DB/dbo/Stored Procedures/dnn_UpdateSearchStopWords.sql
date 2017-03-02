CREATE PROCEDURE [dbo].[dnn_UpdateSearchStopWords]
	@StopWordsID		int,
	@StopWords 			nvarchar(MAX),
	@LastModifiedByUserID 	int
AS
BEGIN	
	UPDATE dbo.dnn_SearchStopWords
			SET				
				StopWords = @StopWords,
				LastModifiedByUserID = @LastModifiedByUserID,
				LastModifiedOnDate = GETUTCDATE()
			WHERE StopWordsID = @StopWordsID
END

