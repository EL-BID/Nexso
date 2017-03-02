CREATE PROCEDURE [dbo].[dnn_AddHostSetting]

	@SettingName		nvarchar(50),
	@SettingValue		nvarchar(256),
	@SettingIsSecure	bit,
	@CreatedByUserID	int
AS
	insert into dnn_HostSettings (
	  SettingName,
	  SettingValue,
	  SettingIsSecure,
	  [CreatedByUserID],
	  [CreatedOnDate],
	  [LastModifiedByUserID],
	  [LastModifiedOnDate]
	) 
	values (
	  @SettingName,
	  @SettingValue,
	  @SettingIsSecure,
	  @CreatedByUserID,
	  getdate(),
	  @CreatedByUserID,
	  getdate()
	)

