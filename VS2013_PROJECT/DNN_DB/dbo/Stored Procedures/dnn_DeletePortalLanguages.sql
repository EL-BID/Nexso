CREATE PROCEDURE [dbo].[dnn_DeletePortalLanguages]
    @PortalId   Int, -- Null ignored (use referential integrity to delete from all Portals)
    @LanguageId Int  -- Null ignored (use referential integrity to delete for all languages)
AS
BEGIN
    IF @PortalId Is Not Null AND IsNull(@LanguageId, -1) != -1 BEGIN
       DECLARE @CultureCode nVarchar(10);
       SELECT @CultureCode = CultureCode FROM dbo.[dnn_Languages] WHERE LanguageId = @LanguageId;
       DELETE FROM dbo.[dnn_PortalLanguages]    WHERE PortalId = @PortalId AND @LanguageId  = LanguageId;
       DELETE FROM dbo.[dnn_PortalLocalization] WHERE PortalId = @PortalId AND @CultureCode = CultureCode;
       DELETE FROM dbo.[dnn_PortalSettings]     WHERE PortalId = @PortalId AND @CultureCode = CultureCode;
    END
    -- ELSE rely on referential integrity (portal or language will be deleted as well)
END

