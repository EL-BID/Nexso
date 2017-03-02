CREATE PROCEDURE [dbo].[dnn_DeleteContentType] 
	@ContentTypeId	int
AS
	DELETE FROM dbo.dnn_ContentTypes
	WHERE ContentTypeId = @ContentTypeId

