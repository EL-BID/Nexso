CREATE PROCEDURE [dbo].[dnn_UpdateFolderMappingsSetting]
	@FolderMappingID int,
	@SettingName nvarchar(50),
	@SettingValue nvarchar(2000),
	@LastModifiedByUserID int
AS
BEGIN
	UPDATE dbo.[dnn_FolderMappingsSettings]
	SET
		SettingValue = @SettingValue,
		LastModifiedByUserID = @LastModifiedByUserID,
		LastModifiedOnDate = GETDATE()
	WHERE FolderMappingID = @FolderMappingID AND SettingName = @SettingName
END

