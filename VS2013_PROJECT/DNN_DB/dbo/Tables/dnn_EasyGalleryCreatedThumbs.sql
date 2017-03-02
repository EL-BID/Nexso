CREATE TABLE [dbo].[dnn_EasyGalleryCreatedThumbs] (
    [ModuleID]     INT NOT NULL,
    [PictureID]    INT NOT NULL,
    [ThumbCreated] BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryCreatedThumbs] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [PictureID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryCreatedThumbs_dnn_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryCreatedThumbs_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

