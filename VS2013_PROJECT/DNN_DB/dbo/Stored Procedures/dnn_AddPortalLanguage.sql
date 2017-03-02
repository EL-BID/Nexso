CREATE PROCEDURE [dbo].[dnn_AddPortalLanguage]
    @PortalId			int,
    @LanguageId			int,
    @IsPublished		bit,
    @CreatedByUserID	int

AS
    INSERT INTO dbo.dnn_PortalLanguages (
        PortalId,
        LanguageId,
        IsPublished,
        [CreatedByUserID],
        [CreatedOnDate],
        [LastModifiedByUserID],
        [LastModifiedOnDate]
    )
    VALUES (
        @PortalId,
        @LanguageId,
        @IsPublished,
        @CreatedByUserID,
        getdate(),
        @CreatedByUserID,
        getdate()
    )

    SELECT SCOPE_IDENTITY()

