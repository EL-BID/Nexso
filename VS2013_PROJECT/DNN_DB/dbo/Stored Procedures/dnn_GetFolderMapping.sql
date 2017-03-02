CREATE PROCEDURE [dbo].[dnn_GetFolderMapping]
	@FolderMappingID int
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_FolderMappings]
	WHERE FolderMappingID = @FolderMappingID
END

