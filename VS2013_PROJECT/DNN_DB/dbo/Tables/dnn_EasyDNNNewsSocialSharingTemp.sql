CREATE TABLE [dbo].[dnn_EasyDNNNewsSocialSharingTemp] (
    [NewsModuleID]  INT     NOT NULL,
    [ArticleID]     INT     NOT NULL,
    [SocialNetwork] TINYINT NOT NULL,
    [SocialGroupID] INT     NOT NULL,
    [SocialUserID]  INT     DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsSocialSharingTemp] PRIMARY KEY CLUSTERED ([NewsModuleID] ASC, [ArticleID] ASC, [SocialNetwork] ASC, [SocialGroupID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialSharingTemp_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialSharingTemp_Modules] FOREIGN KEY ([NewsModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialSharingTemp_Roles] FOREIGN KEY ([SocialGroupID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

