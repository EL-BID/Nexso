CREATE PROCEDURE [dbo].[dnn_DeleteFolderMapping]
	@FolderMappingID int
AS
BEGIN
	DELETE
	FROM dbo.[dnn_FolderMappings]
	WHERE FolderMappingID = @FolderMappingID
END

