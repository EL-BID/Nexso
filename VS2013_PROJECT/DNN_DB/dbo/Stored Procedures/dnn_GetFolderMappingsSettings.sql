CREATE PROCEDURE [dbo].[dnn_GetFolderMappingsSettings]
	@FolderMappingID int
AS
BEGIN
	SELECT SettingName, SettingValue
	FROM dbo.[dnn_FolderMappingsSettings]
	WHERE FolderMappingID = @FolderMappingID
END

