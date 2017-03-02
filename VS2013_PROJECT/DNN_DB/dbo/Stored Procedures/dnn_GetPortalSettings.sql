CREATE PROCEDURE [dbo].[dnn_GetPortalSettings]
    @PortalId    Int,            -- not Null!
    @CultureCode nVarChar(20)    -- Null|'' for neutral language
AS
BEGIN
	DECLARE @DefaultLanguage nVarChar(20) = '';

	IF EXISTS (SELECT * FROM dbo.[dnn_PortalLocalization] L
					JOIN dbo.[dnn_Portals] P ON L.PortalID = P.PortalID AND L.CultureCode = P.DefaultLanguage
					WHERE P.PortalID = @PortalID)
		SELECT @DefaultLanguage = DefaultLanguage 
		FROM dbo.[dnn_Portals] 
		WHERE PortalID = @PortalID

	SELECT
		PS.SettingName,
		CASE WHEN Lower(PS.SettingValue) LIKE 'fileid=%'
			THEN dbo.dnn_FilePath(PS.SettingValue)
			ELSE PS.SettingValue END   AS SettingValue,
		PS.CreatedByUserID,
		PS.CreatedOnDate,
		PS.LastModifiedByUserID,
		PS.LastModifiedOnDate,
		PS.CultureCode
		FROM dbo.[dnn_PortalSettings] PS
	WHERE 
		PortalID = @PortalId  AND 
		COALESCE(CultureCode, @CultureCode, @DefaultLanguage) = IsNull(@CultureCode, @DefaultLanguage)
END

