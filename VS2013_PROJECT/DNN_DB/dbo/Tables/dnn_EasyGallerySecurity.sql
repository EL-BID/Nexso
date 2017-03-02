CREATE TABLE [dbo].[dnn_EasyGallerySecurity] (
    [GalleryID]   INT           NOT NULL,
    [SecurityKey] NVARCHAR (50) CONSTRAINT [DF_dnn_EasyGallerySecurity_SecurityKey] DEFAULT (N'E') NOT NULL,
    CONSTRAINT [PK_dnn_EasyGallerySecurity] PRIMARY KEY CLUSTERED ([GalleryID] ASC, [SecurityKey] ASC),
    CONSTRAINT [FK_dnn_EasyGallerySecurity_dnn_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE
);

