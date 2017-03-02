CREATE PROCEDURE [dbo].[dnn_DeleteMetaData] 
	@ContentItemId		int,
	@Name				nvarchar(100),
	@Value				nvarchar(MAX)
	
AS
	DELETE FROM dbo.dnn_ContentItems_MetaData
	FROM dbo.dnn_ContentItems_MetaData AS cm
		INNER JOIN dbo.dnn_MetaData AS m ON cm.MetaDataID = m.MetaDataID
	WHERE cm.ContentItemId = @ContentItemId AND m.MetaDataName = @Name AND cm.MetaDataValue = @Value

