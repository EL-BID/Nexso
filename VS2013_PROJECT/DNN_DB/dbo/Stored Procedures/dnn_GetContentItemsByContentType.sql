CREATE PROCEDURE [dbo].[dnn_GetContentItemsByContentType] 
	@ContentTypeId int
AS
	SELECT * FROM dbo.dnn_ContentItems WHERE ContentTypeID = @ContentTypeId

