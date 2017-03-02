CREATE PROCEDURE [dbo].[dnn_AddFolderMappingsSetting]
	@FolderMappingID int,
	@SettingName nvarchar(50),
	@SettingValue nvarchar(2000),
	@CreatedByUserID int
AS
BEGIN
	INSERT INTO dbo.[dnn_FolderMappingsSettings] (
		FolderMappingID,
		SettingName,
		SettingValue,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	)
	VALUES (
		@FolderMappingID,
		@SettingName,
		@SettingValue,
		@CreatedByUserID,
		GETDATE(),
		@CreatedByUserID,
		GETDATE()
	)
END

