CREATE TABLE [dbo].[dnn_EasyDNNNewsSocialSharingStatistics] (
    [StatisticID]       INT            IDENTITY (1, 1) NOT NULL,
    [ArticleID]         INT            NOT NULL,
    [UserID]            INT            NULL,
    [SocialNetwork]     TINYINT        NOT NULL,
    [PostedToAccountID] VARCHAR (250)  NOT NULL,
    [PostedToName]      NVARCHAR (350) NOT NULL,
    [PostType]          TINYINT        NOT NULL,
    [PostDateTime]      DATETIME       NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsSocialSharingArchive] PRIMARY KEY CLUSTERED ([StatisticID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialSharingStatistics_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsSocialSharingStatistics_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);

