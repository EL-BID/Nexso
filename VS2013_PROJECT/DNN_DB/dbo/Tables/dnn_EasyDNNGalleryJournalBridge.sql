CREATE TABLE [dbo].[dnn_EasyDNNGalleryJournalBridge] (
    [PortalID]                INT      NOT NULL,
    [JournalCategoryID]       INT      NOT NULL,
    [Enabled]                 BIT      NOT NULL,
    [LastCheck]               DATETIME NULL,
    [UserGalleriesCategoryID] INT      NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNGalleryJournalBridge] PRIMARY KEY CLUSTERED ([PortalID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNGalleryJournalBridge_dnn_EasyGalleryCategory] FOREIGN KEY ([JournalCategoryID]) REFERENCES [dbo].[dnn_EasyGalleryCategory] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNGalleryJournalBridge_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

