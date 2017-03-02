CREATE TABLE [dbo].[dnn_EasyGalleryMediaDownloadInfo] (
    [DownloadInfoID] INT           IDENTITY (1, 1) NOT NULL,
    [PictureID]      INT           NOT NULL,
    [UserID]         INT           NULL,
    [DateDownload]   DATETIME      CONSTRAINT [DF_dnn_EasyGalleryMediaDownloadInfo_DateDownload] DEFAULT (getutcdate()) NOT NULL,
    [DownloadIP]     NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryMediaDownloadInfo] PRIMARY KEY CLUSTERED ([DownloadInfoID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryMediaDownloadInfo_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryMediaDownloadInfo_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);

