create procedure [dbo].[dnn_DeleteTabModuleSetting]
@TabModuleId      int,
@SettingName   nvarchar(50)
as

DELETE FROM dnn_TabModuleSettings 
WHERE TabModuleId = @TabModuleId
AND SettingName = @SettingName

