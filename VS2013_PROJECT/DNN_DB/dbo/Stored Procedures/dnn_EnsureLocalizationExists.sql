CREATE PROCEDURE [dbo].[dnn_EnsureLocalizationExists]
    @PortalID       Int,
    @CultureCode    nvarchar(10)
AS
BEGIN
    DECLARE @MasterLanguage nvarchar(10) = Null;
    DECLARE @LocalizationExists bit = 0;

    IF NOT EXISTS (SELECT * FROM dbo.[dnn_Languages] L 
                    JOIN dbo.[dnn_PortalLanguages] P ON L.LanguageID = P.LanguageID 
                    WHERE P.PortalID = @PortalID AND L.CultureCode = @CultureCode)
        RETURN; -- language does not exist for this portal

    IF EXISTS (SELECT * FROM dbo.[dnn_PortalLocalization] 
                WHERE CultureCode = @CultureCode AND PortalID = @PortalID)
        RETURN; -- already localized
    
    IF EXISTS (SELECT * FROM dbo.[dnn_PortalLocalization] L
                    JOIN dbo.[dnn_Portals] P ON L.PortalID = P.PortalID AND L.CultureCode = P.DefaultLanguage
                    WHERE P.PortalID = @PortalID)
        SELECT @MasterLanguage = DefaultLanguage 
        FROM dbo.[dnn_Portals] 
        WHERE PortalID = @PortalID
    ELSE IF EXISTS (SELECT * FROM dbo.[dnn_PortalLocalization] 
                    WHERE CultureCode = 'en-US' and PortalID = @PortalID)
        SET @MasterLanguage = 'en-US'
    ELSE -- neither default nor system language available: take the language that was assigned first
        SELECT TOP (1) @MasterLanguage = CultureCode 
        FROM dbo.[dnn_PortalLocalization] 
        WHERE PortalID = @PortalID 
        ORDER BY PortalID ASC;

    IF NOT (@MasterLanguage Is Null OR @MasterLanguage LIKE @CultureCode) 
    BEGIN  -- copy localized values from (existing and different) master language:                    
        INSERT INTO dbo.[dnn_PortalLocalization]
        (    PortalId,
            CultureCode,
            PortalName,
            LogoFile,
            FooterText,
            Description,
            KeyWords,
            BackgroundFile, 
            HomeTabId,
            LoginTabId,
            UserTabId,
            AdminTabId,
            RegisterTabId,
            SearchTabId,
            Custom404TabId,
            Custom500TabId,
            CreatedByUserID,
            CreatedOnDate,
            LastModifiedByUserID,
            LastModifiedOnDate
        ) SELECT
            PortalId,
            @CultureCode,
            PortalName,
            LogoFile,
            FooterText,
            Description,
            KeyWords,
            BackgroundFile, 
            HomeTabId,
            LoginTabId,
            UserTabId,
            AdminTabId,
            RegisterTabId,
            SearchTabId,
            Custom404TabId,
            Custom500TabId,
            -1,
            GETDATE(),
            -1,
            GETDATE()
         FROM dbo.[dnn_PortalLocalization] 
         WHERE PortalID = @PortalID AND CultureCode = @MasterLanguage;
    
        -- copy missing localized settings:
        DECLARE    
            @LocalPortalSettings TABLE(
            [PortalID]             INT             NOT NULL,
            [CultureCode]          NVARCHAR (10)   NOT NULL,
            [SettingName]          NVARCHAR (50)   NOT NULL,
            [SettingValue]         NVARCHAR (2000) NULL
        );

        INSERT INTO @LocalPortalSettings
        (
            PortalID,
            CultureCode,
            SettingName,
            SettingValue
        )
        SELECT
            PortalID,
            CultureCode,
            SettingName,
            SettingValue
        FROM dbo.[dnn_PortalSettings]
        WHERE PortalID = @PortalID AND CultureCode = @CultureCode

        MERGE INTO @LocalPortalSettings target
        USING (SELECT * FROM dbo.[dnn_PortalSettings]
                WHERE PortalId = @PortalID and CultureCode = @MasterLanguage) source 
        ON (target.SettingName = source.SettingName)
        WHEN NOT MATCHED THEN 
            INSERT (  
                PortalID,   
                CultureCode,   
                SettingName,   
                SettingValue) 
            VALUES (
                source.PortalID, 
                @CultureCode, 
                source.SettingName, 
                source.SettingValue
            );

        MERGE INTO dbo.[dnn_PortalSettings]  target
        USING (SELECT * FROM @LocalPortalSettings) source 
        ON (target.PortalID = source.PortalID AND 
            target.CultureCode = source.CultureCode AND 
            target.SettingName = source.SettingName)
        WHEN NOT MATCHED THEN 
            INSERT (  
                PortalID,   
                CultureCode,   
                SettingName,   
                SettingValue,
                CreatedByUserID, 
                CreatedOnDate, 
                LastModifiedByUserID, 
                LastModifiedOnDate) 
            VALUES (
                source.PortalID, 
                @CultureCode, 
                source.SettingName, 
                source.SettingValue,
                -1,
                GETDATE(),
                -1,
                GETDATE()
            );
    END;
END
