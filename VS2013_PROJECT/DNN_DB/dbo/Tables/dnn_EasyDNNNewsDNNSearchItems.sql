CREATE TABLE [dbo].[dnn_EasyDNNNewsDNNSearchItems] (
    [ModuleID]  INT NOT NULL,
    [ArticleID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsDNNSearchItems] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsDNNSearchItems_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsDNNSearchItems_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

