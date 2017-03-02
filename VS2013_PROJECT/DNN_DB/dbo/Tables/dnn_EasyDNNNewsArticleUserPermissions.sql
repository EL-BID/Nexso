CREATE TABLE [dbo].[dnn_EasyDNNNewsArticleUserPermissions] (
    [ArticleUserItemID] INT IDENTITY (1, 1) NOT NULL,
    [ArticleID]         INT NOT NULL,
    [UserID]            INT NULL,
    [Show]              BIT NOT NULL,
    [Edit]              BIT NOT NULL,
    [EventRegistration] BIT CONSTRAINT [DF_dnn_EasyDNNNewsArticleUserPermissions_EventRegistration] DEFAULT ((0)) NOT NULL,
    [DocumentDownload]  BIT CONSTRAINT [DF_dnn_EasyDNNNewsArticleUserPermissions_DocumentDownload] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsArticleUserPermissions_1] PRIMARY KEY CLUSTERED ([ArticleUserItemID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleUserPermissions_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleUserPermissions_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsArticleUserPermissions] UNIQUE NONCLUSTERED ([ArticleID] ASC, [UserID] ASC)
);

