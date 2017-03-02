CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalFilterByArticles] (
    [FilterPortalID] INT NOT NULL,
    [ArticleID]      INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalFilterByArticles] PRIMARY KEY CLUSTERED ([FilterPortalID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalArticlesFilter_Portals] FOREIGN KEY ([FilterPortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalFilterByArticles_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);

