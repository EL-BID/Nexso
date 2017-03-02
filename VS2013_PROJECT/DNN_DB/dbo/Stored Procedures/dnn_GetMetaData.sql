CREATE PROCEDURE [dbo].[dnn_GetMetaData] 
	@ContentItemId   int
AS
	SELECT md.MetaDataName, cmd.MetaDataValue
	FROM dbo.[dnn_ContentItems_MetaData] cmd
	JOIN dbo.[dnn_MetaData] md on (cmd.MetaDataID = md.MetaDataID)
	WHERE ContentItemId = @ContentItemId

