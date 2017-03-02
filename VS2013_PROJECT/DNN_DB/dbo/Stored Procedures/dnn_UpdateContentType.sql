CREATE PROCEDURE [dbo].[dnn_UpdateContentType] 
	@ContentTypeId		int,
	@ContentType		nvarchar(250)
AS
	UPDATE dbo.dnn_ContentTypes 
		SET 
			ContentType = @ContentType
	WHERE ContentTypeId = @ContentTypeId

