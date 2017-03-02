CREATE TABLE [dbo].[dnn_PortalLanguages] (
    [PortalLanguageID]     INT      IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT      NOT NULL,
    [LanguageID]           INT      NOT NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    [IsPublished]          BIT      CONSTRAINT [DF_dnn_PortalLanguages_IsPublished] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_PortalLanguages] PRIMARY KEY CLUSTERED ([PortalLanguageID] ASC),
    CONSTRAINT [FK_dnn_PortalLanguages_dnn_PortalLanguages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[dnn_Languages] ([LanguageID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_PortalLanguages_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_PortalLanguages]
    ON [dbo].[dnn_PortalLanguages]([PortalID] ASC, [LanguageID] ASC);

