create procedure [dbo].[dnn_GetHostSetting]

@SettingName nvarchar(50)

as

select SettingValue
from dbo.dnn_HostSettings
where  SettingName = @SettingName

