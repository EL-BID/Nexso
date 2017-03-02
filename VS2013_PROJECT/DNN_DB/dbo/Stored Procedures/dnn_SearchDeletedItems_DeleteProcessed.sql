CREATE PROCEDURE [dbo].[dnn_SearchDeletedItems_DeleteProcessed]
    @CutoffTime	DATETIME
AS
BEGIN
	DELETE FROM dbo.dnn_SearchDeletedItems
	WHERE [DateCreated] < @CutoffTime
END

