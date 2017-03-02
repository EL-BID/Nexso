CREATE TABLE [dbo].[dnn_EasyDNNNewsArticleGoogleMapConnection] (
    [ArticleID]   INT NOT NULL,
    [GoogleMapID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsArticleGoogleMapConnection] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [GoogleMapID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleGoogleMapConnection_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleGoogleMapConnection_EasyDNNnewsGoogleMapsData] FOREIGN KEY ([GoogleMapID]) REFERENCES [dbo].[dnn_EasyDNNnewsGoogleMapsData] ([GoogleMapID])
);

