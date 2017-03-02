CREATE PROCEDURE [dbo].[dnn_AddTabModuleSetting]
	@TabModuleId   		int,
	@SettingName   		nvarchar(50),
	@SettingValue  		nvarchar(max),
	@CreatedByUserID  	int
AS
	INSERT INTO dbo.dnn_TabModuleSettings ( 
		TabModuleId,
		SettingName, 
		SettingValue,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	) 
	VALUES ( 
		@TabModuleId,
		@SettingName, 
		@SettingValue,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

