CREATE TABLE [dbo].[dnn_EasyGalleryUserLikes] (
    [PictureID] INT      NOT NULL,
    [UserID]    INT      NOT NULL,
    [LikeDate]  DATETIME CONSTRAINT [DF_dnn_EasyGalleryUserLikes_LikeDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryUserLikes] PRIMARY KEY CLUSTERED ([PictureID] ASC, [UserID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryUserLikes_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryUserLikes_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

