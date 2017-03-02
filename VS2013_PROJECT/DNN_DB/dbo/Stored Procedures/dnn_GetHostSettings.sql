CREATE PROCEDURE [dbo].[dnn_GetHostSettings]
AS
	IF NOT EXISTS ( select 1 from dbo.dnn_HostSettings where SettingName = 'GUID' )
	  INSERT INTO dbo.dnn_HostSettings ( SettingName, SettingValue, SettingIsSecure ) values ( 'GUID', newid(), 0 )

	SELECT SettingName,
		   SettingValue,
		   SettingIsSecure,
		   CreatedByUserID,
		   CreatedOnDate,
	       LastModifiedByUserID,
		   LastModifiedOnDate
	FROM   dbo.dnn_HostSettings

