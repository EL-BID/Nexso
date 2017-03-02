create procedure [dbo].[dnn_DeleteModuleSetting]
@ModuleId      int,
@SettingName   nvarchar(50)
as

DELETE FROM dbo.dnn_ModuleSettings 
WHERE ModuleId = @ModuleId
AND SettingName = @SettingName

