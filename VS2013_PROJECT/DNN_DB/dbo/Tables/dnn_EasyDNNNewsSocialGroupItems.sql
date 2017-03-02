CREATE TABLE [dbo].[dnn_EasyDNNNewsSocialGroupItems] (
    [RoleID]    INT NOT NULL,
    [ArticleID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsSocialGroupItems] PRIMARY KEY CLUSTERED ([RoleID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialGroupItems_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialGroupItems_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

