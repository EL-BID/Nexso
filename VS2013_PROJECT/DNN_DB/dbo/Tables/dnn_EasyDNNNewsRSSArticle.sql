CREATE TABLE [dbo].[dnn_EasyDNNNewsRSSArticle] (
    [RSSID]     INT             NOT NULL,
    [ArticleID] INT             NOT NULL,
    [PortalID]  INT             NOT NULL,
    [CheckType] NVARCHAR (5)    NOT NULL,
    [CheckData] NVARCHAR (1000) NOT NULL,
    [FeedType]  NVARCHAR (10)   NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsRSSArticle] PRIMARY KEY CLUSTERED ([RSSID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsRSSArticle_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsRSSArticle_EasyDNNNewsRSSFeedImport] FOREIGN KEY ([RSSID]) REFERENCES [dbo].[dnn_EasyDNNNewsRSSFeedImport] ([RSSID]) ON DELETE CASCADE
);

