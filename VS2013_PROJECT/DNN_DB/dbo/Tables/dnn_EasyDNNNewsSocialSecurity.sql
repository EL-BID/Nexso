CREATE TABLE [dbo].[dnn_EasyDNNNewsSocialSecurity] (
    [ArticleID]   INT           NOT NULL,
    [SecurityKey] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsSocialSecurity] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [SecurityKey] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialSecurity_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);

