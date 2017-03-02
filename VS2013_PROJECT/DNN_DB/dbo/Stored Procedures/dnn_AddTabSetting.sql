CREATE PROCEDURE [dbo].[dnn_AddTabSetting]
	@TabID				INT,
	@SettingName		NVARCHAR(50),
	@SettingValue		NVARCHAR(2000),
	@CreatedByUserID	INT

AS

	INSERT INTO dbo.dnn_TabSettings ( 
		TabID,
		SettingName,
		SettingValue,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	) 
	VALUES ( 
		@TabId, 
		@SettingName, 
		@SettingValue,
		@CreatedByUserID,
		GETDATE(),
		@CreatedByUserID,
		GETDATE()
	)

