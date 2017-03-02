CREATE TABLE [dbo].[dnn_EasyDNNNewsArticleRolePermissions] (
    [ArticleID]         INT NOT NULL,
    [RoleID]            INT NOT NULL,
    [Show]              BIT NOT NULL,
    [Edit]              BIT NOT NULL,
    [EventRegistration] BIT CONSTRAINT [DF_dnn_EasyDNNNewsArticleRolePermissions_EventRegistration] DEFAULT ((0)) NOT NULL,
    [DocumentDownload]  BIT CONSTRAINT [DF_dnn_EasyDNNNewsArticleRolePermissions_DocumentDownload] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsArticleRolePermissions] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [RoleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleRolePermissions_EasyDNNNewsArticleRolePermissions] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsArticleRolePermissions_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

