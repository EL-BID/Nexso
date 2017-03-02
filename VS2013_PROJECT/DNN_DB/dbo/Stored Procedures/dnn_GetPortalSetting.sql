CREATE PROCEDURE [dbo].[dnn_GetPortalSetting]
    @PortalID    Int,		    -- Not Null
    @SettingName nVarChar(50),	-- Not Null
    @CultureCode nVarChar(50)	-- Null|-1 for neutral language
AS
BEGIN
	SELECT TOP (1)
		SettingName,
		CASE WHEN Lower(SettingValue) Like 'fileid=%'
		 THEN dbo.[dnn_FilePath](SettingValue)
		 ELSE SettingValue 
		END   AS SettingValue,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate,
		CultureCode
	 FROM  dbo.[dnn_PortalSettings]
	 WHERE PortalID    = @PortalID
	   AND SettingName = @SettingName
	   AND COALESCE(CultureCode, @CultureCode,'') = IsNull(@CultureCode,'')
	 ORDER BY IsNull(CultureCode,'') DESC
END

