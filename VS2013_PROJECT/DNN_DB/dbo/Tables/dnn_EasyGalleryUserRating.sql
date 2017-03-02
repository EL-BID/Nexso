CREATE TABLE [dbo].[dnn_EasyGalleryUserRating] (
    [PictureID] INT             NOT NULL,
    [UserID]    INT             NOT NULL,
    [Value]     DECIMAL (18, 4) NOT NULL,
    [RateDate]  DATETIME        NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryUserRating] PRIMARY KEY CLUSTERED ([PictureID] ASC, [UserID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryUserRating_dnn_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryUserRating_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

