CREATE TABLE [dbo].[dnn_EasyGalleryIntegration] (
    [EntryID]     INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]    INT            NULL,
    [ModuleID]    INT            NULL,
    [ArticleID]   INT            NULL,
    [GalleryID]   INT            NULL,
    [GalleryName] NVARCHAR (500) NULL,
    CONSTRAINT [PK_dnn_EasyGalleryIntegration] PRIMARY KEY CLUSTERED ([EntryID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryIntegration_dnn_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE
);

