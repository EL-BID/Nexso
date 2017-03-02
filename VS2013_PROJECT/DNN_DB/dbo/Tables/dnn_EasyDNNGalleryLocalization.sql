CREATE TABLE [dbo].[dnn_EasyDNNGalleryLocalization] (
    [GalleryID]    INT             NOT NULL,
    [PortalID]     INT             NOT NULL,
    [LocaleCode]   NVARCHAR (20)   NOT NULL,
    [LocaleString] NVARCHAR (150)  NULL,
    [Title]        NVARCHAR (500)  NULL,
    [Description]  NVARCHAR (2000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNGalleryLocalization] PRIMARY KEY CLUSTERED ([GalleryID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNGalleryLocalization_dnn_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE
);

