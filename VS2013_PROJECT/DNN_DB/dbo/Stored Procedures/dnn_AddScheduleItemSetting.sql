CREATE PROCEDURE [dbo].[dnn_AddScheduleItemSetting]
	@ScheduleID int,
	@Name nvarchar(50),
	@Value nvarchar(256)
AS
BEGIN
	UPDATE dbo.[dnn_ScheduleItemSettings]
	SET SettingValue = @Value
	WHERE ScheduleID = @ScheduleID
	AND SettingName = @Name

	IF @@ROWCOUNT = 0 BEGIN
		INSERT INTO dbo.[dnn_ScheduleItemSettings] (ScheduleID, SettingName, Settingvalue)
		VALUES (@ScheduleID, @Name, @Value)
	END
END

