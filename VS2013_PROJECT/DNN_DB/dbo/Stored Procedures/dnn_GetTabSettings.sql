CREATE PROCEDURE [dbo].[dnn_GetTabSettings]
    @PortalId Int
AS
	BEGIN
		SELECT
			TS.TabID,
			TS.SettingName,
			CASE WHEN Lower(TS.SettingValue) LIKE 'fileid=%'
				 THEN dbo.dnn_FilePath(TS.SettingValue)
				 ELSE TS.SettingValue END           
				 AS SettingValue
		FROM   dbo.[dnn_TabSettings] TS
			INNER JOIN dbo.[dnn_Tabs] T ON t.TabID = TS.TabID
		WHERE  (PortalId = @PortalId)
		ORDER BY TS.TabID
	END

