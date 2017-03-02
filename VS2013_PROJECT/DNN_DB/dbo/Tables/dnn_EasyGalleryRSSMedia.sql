CREATE TABLE [dbo].[dnn_EasyGalleryRSSMedia] (
    [RSSID]     INT             NOT NULL,
    [PictureID] INT             NOT NULL,
    [PortalID]  INT             NOT NULL,
    [CheckType] NVARCHAR (5)    NOT NULL,
    [CheckData] NVARCHAR (1000) NOT NULL,
    [FeedType]  NVARCHAR (10)   NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryRssMedia] PRIMARY KEY CLUSTERED ([RSSID] ASC, [PictureID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryRssMedia_dnn_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE
);

