CREATE TABLE [dbo].[dnn_EasyGalleryImageSizes] (
    [PictureID]    INT     NOT NULL,
    [Width]        INT     NOT NULL,
    [Height]       INT     NOT NULL,
    [ResizeMethod] TINYINT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryImageSizes] PRIMARY KEY CLUSTERED ([PictureID] ASC, [Width] ASC, [Height] ASC, [ResizeMethod] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryImageSizes_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE
);

