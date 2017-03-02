CREATE PROCEDURE [dbo].[dnn_GetFolderMappingsSetting]
	@FolderMappingID int,
	@SettingName nvarchar(50)
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_FolderMappingsSettings]
	WHERE FolderMappingID = @FolderMappingID AND SettingName = @SettingName
END

