CREATE PROCEDURE [dbo].[dnn_DeleteTabSetting]
	@TabID      	INT,
	@SettingName	NVARCHAR(50)

AS

	DELETE	FROM dbo.dnn_TabSettings 
	WHERE	TabID = @TabID
	AND		SettingName = @SettingName

