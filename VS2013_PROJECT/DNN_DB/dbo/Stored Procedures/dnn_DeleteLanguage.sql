CREATE PROCEDURE [dbo].[dnn_DeleteLanguage]
	@LanguageID		Int -- Not Null
AS
BEGIN
    DECLARE @CultureCode AS nVarChar(10);
    SELECT @CultureCode = CultureCode FROM dbo.[dnn_Languages] WHERE LanguageId = @LanguageId;
    DELETE FROM dbo.[dnn_PortalLocalization] WHERE @CultureCode = CultureCode;
    DELETE FROM dbo.[dnn_PortalSettings]     WHERE @CultureCode = CultureCode;
    DELETE FROM dbo.[dnn_Languages]          WHERE @LanguageID  = LanguageID;
END

