CREATE PROCEDURE [dbo].[dnn_AddModuleSetting]
	@ModuleId			int,
	@SettingName		nvarchar(50),
	@SettingValue		nvarchar(max),
	@CreatedByUserID	int
AS
	INSERT INTO dbo.dnn_ModuleSettings ( 
		ModuleId,
		SettingName,
		SettingValue,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	) 
	VALUES ( 
		@ModuleId, 
		@SettingName, 
		@SettingValue,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

