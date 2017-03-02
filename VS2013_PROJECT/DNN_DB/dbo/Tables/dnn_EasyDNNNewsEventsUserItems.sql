CREATE TABLE [dbo].[dnn_EasyDNNNewsEventsUserItems] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [EventUserID]        INT             NOT NULL,
    [ArticleID]          INT             NULL,
    [RecurringArticleID] INT             NULL,
    [RecurringID]        INT             NULL,
    [ApproveStatus]      TINYINT         NOT NULL,
    [CreatedOnDate]      DATETIME        NOT NULL,
    [LastModifiedDate]   DATETIME        NOT NULL,
    [NumberOfTickets]    SMALLINT        NOT NULL,
    [Message]            NVARCHAR (1024) NULL,
    [UserStatus]         TINYINT         CONSTRAINT [DF_dnn_EasyDNNNewsEventsUserItems_UserStatus] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventsUserItems] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_dnn_EasyDNNNewsEventsUserItems_checkValues] CHECK ((1)=case when [ArticleID] IS NOT NULL AND [RecurringArticleID] IS NULL AND [RecurringID] IS NULL OR [ArticleID] IS NULL AND [RecurringArticleID] IS NOT NULL AND [RecurringID] IS NOT NULL then (1) else (0) end),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsUserItems_EasyDNNNewsEventsData] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsData] ([ArticleID]),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsUserItems_EasyDNNNewsEventsRecurringData] FOREIGN KEY ([RecurringArticleID], [RecurringID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsRecurringData] ([ArticleID], [RecurringID]),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsUserItems_EasyDNNNewsEventUsers] FOREIGN KEY ([EventUserID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventUsers] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsEventsUserItems] UNIQUE NONCLUSTERED ([EventUserID] ASC, [ArticleID] ASC, [RecurringArticleID] ASC, [RecurringID] ASC)
);

