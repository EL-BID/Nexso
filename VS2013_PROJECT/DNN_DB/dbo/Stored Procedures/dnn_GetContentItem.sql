CREATE PROCEDURE [dbo].[dnn_GetContentItem] 
	@ContentItemId			int
AS
	SELECT *
	FROM dbo.dnn_ContentItems
	WHERE ContentItemId = @ContentItemId

