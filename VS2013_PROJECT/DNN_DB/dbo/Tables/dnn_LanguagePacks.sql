CREATE TABLE [dbo].[dnn_LanguagePacks] (
    [LanguagePackID]       INT      IDENTITY (1, 1) NOT NULL,
    [PackageID]            INT      NOT NULL,
    [DependentPackageID]   INT      NOT NULL,
    [LanguageID]           INT      NOT NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    CONSTRAINT [PK_dnn_LanguagePacks] PRIMARY KEY CLUSTERED ([LanguagePackID] ASC),
    CONSTRAINT [FK_dnn_LanguagePacks_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_LanguagePacks]
    ON [dbo].[dnn_LanguagePacks]([LanguageID] ASC, [PackageID] ASC);

