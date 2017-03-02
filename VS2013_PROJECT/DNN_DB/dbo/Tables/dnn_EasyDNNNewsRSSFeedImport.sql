CREATE TABLE [dbo].[dnn_EasyDNNNewsRSSFeedImport] (
    [RSSID]               INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]            INT             NOT NULL,
    [RSSURL]              NVARCHAR (1000) NOT NULL,
    [UserID]              INT             NOT NULL,
    [CategoryID]          INT             NOT NULL,
    [Active]              BIT             NOT NULL,
    [PortalHomeDir]       NVARCHAR (1000) NOT NULL,
    [DownloadImages]      BIT             NOT NULL,
    [LimitArticlesNumber] INT             NOT NULL,
    [RSSType]             NVARCHAR (20)   DEFAULT ('Standard') NOT NULL,
    [SummaryLimit]        INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsRSSFeedImport] PRIMARY KEY CLUSTERED ([RSSID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsRSSFeedImport_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsRSSFeedImport_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsRSSFeedImport_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

