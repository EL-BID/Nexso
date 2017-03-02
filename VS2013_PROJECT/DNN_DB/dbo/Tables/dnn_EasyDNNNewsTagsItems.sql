CREATE TABLE [dbo].[dnn_EasyDNNNewsTagsItems] (
    [ArticleID] INT      NOT NULL,
    [TagID]     INT      NOT NULL,
    [DateAdded] DATETIME CONSTRAINT [DF_dnn_EasyDNNNewsTagsItems_DateAdded] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsTagsItems] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [TagID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsTagsItems_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsTagsItems_EasyDNNNewsNewTags] FOREIGN KEY ([TagID]) REFERENCES [dbo].[dnn_EasyDNNNewsNewTags] ([TagID]) ON DELETE CASCADE
);

