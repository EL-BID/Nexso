CREATE PROCEDURE [dbo].[dnn_UpdatePortalLanguage]
    @PortalId				int,
    @LanguageId				int,
    @IsPublished			bit,
    @LastModifiedByUserID  	int

AS
    UPDATE dbo.dnn_PortalLanguages 
        SET		
            IsPublished				= @IsPublished,
            LastModifiedByUserID	= @LastModifiedByUserID,
            LastModifiedOnDate		= getdate()
    WHERE PortalId = @PortalId
        AND LanguageId = @LanguageId

