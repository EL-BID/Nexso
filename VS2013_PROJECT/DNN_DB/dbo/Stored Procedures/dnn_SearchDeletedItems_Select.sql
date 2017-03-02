CREATE PROCEDURE [dbo].[dnn_SearchDeletedItems_Select]
    @CutoffTime	DATETIME
AS
BEGIN
	SELECT document
	FROM dbo.dnn_SearchDeletedItems
	WHERE [DateCreated] < @CutoffTime
	ORDER BY [DateCreated]
END

