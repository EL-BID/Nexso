CREATE TABLE [dbo].[dnn_EasyDNNNewsFilterByArticles] (
    [FilterModuleID] INT NOT NULL,
    [ArticleID]      INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsFilterByArticles] PRIMARY KEY CLUSTERED ([FilterModuleID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsFilterByArticles_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsFilterByArticles_Modules] FOREIGN KEY ([FilterModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

