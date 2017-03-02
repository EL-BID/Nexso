CREATE PROCEDURE [dbo].[dnn_DeleteContentItem] 
	@ContentItemId			int
AS
	DELETE FROM dbo.dnn_ContentItems
	WHERE ContentItemId = @ContentItemId

