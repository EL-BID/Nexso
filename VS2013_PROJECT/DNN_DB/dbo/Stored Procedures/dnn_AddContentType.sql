CREATE PROCEDURE [dbo].[dnn_AddContentType] 
	@ContentType	nvarchar(250)
AS
	INSERT INTO dbo.dnn_ContentTypes (
		ContentType
	)

	VALUES (
		@ContentType
	)

	SELECT SCOPE_IDENTITY()

