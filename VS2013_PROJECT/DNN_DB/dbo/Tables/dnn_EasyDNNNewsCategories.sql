CREATE TABLE [dbo].[dnn_EasyDNNNewsCategories] (
    [EntryID]    INT IDENTITY (1, 1) NOT NULL,
    [ArticleID]  INT NOT NULL,
    [CategoryID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsCategories] PRIMARY KEY CLUSTERED ([EntryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsCategories_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsCategories_EasyDNNNewsCategoryList1] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsCategories_FK_ArticleID]
    ON [dbo].[dnn_EasyDNNNewsCategories]([ArticleID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsCategories_FK_CategoryID]
    ON [dbo].[dnn_EasyDNNNewsCategories]([CategoryID] ASC);

