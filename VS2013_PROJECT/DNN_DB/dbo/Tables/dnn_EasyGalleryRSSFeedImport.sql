CREATE TABLE [dbo].[dnn_EasyGalleryRSSFeedImport] (
    [RSSID]                  INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]               INT             NOT NULL,
    [RSSURL]                 NVARCHAR (1000) NOT NULL,
    [UserID]                 INT             NOT NULL,
    [CategoryID]             INT             NOT NULL,
    [GalleryID]              INT             NOT NULL,
    [Active]                 BIT             NOT NULL,
    [UseTitle]               BIT             NOT NULL,
    [UseDescription]         BIT             NOT NULL,
    [PortalHomeDir]          NVARCHAR (1000) NOT NULL,
    [LimitNumberOfImages]    INT             NOT NULL,
    [SummaryLimit]           INT             NOT NULL,
    [RSSType]                NVARCHAR (20)   NOT NULL,
    [ModuleID]               INT             CONSTRAINT [DF_dnn_EasyGalleryRSSFeedImport_ModuleID] DEFAULT ((322)) NOT NULL,
    [ImportYouTubeStats]     BIT             CONSTRAINT [DF_dnn_EasyGalleryRSSFeedImport_ImportYouTubeStats] DEFAULT ((0)) NOT NULL,
    [DownloadEnclosureMedia] BIT             CONSTRAINT [DF_dnn_EasyGalleryRSSFeedImport_DownloadEnclosureMedia] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryRSSFeedImport] PRIMARY KEY CLUSTERED ([RSSID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryRSSFeedImport_dnn_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryRSSFeedImport_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

