CREATE TABLE [dbo].[dnn_Languages] (
    [LanguageID]           INT            IDENTITY (1, 1) NOT NULL,
    [CultureCode]          NVARCHAR (50)  NOT NULL,
    [CultureName]          NVARCHAR (200) NOT NULL,
    [FallbackCulture]      NVARCHAR (50)  NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_Languages] PRIMARY KEY CLUSTERED ([LanguageID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Languages]
    ON [dbo].[dnn_Languages]([CultureCode] ASC);

