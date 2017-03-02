CREATE TABLE [dbo].[dnn_CoreMessaging_Messages] (
    [MessageID]            INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT             NULL,
    [NotificationTypeID]   INT             NULL,
    [To]                   NVARCHAR (2000) NULL,
    [From]                 NVARCHAR (200)  NULL,
    [Subject]              NVARCHAR (400)  NULL,
    [Body]                 NVARCHAR (MAX)  NULL,
    [ConversationID]       INT             NULL,
    [ReplyAllAllowed]      BIT             NULL,
    [SenderUserID]         INT             NULL,
    [ExpirationDate]       DATETIME        NULL,
    [Context]              NVARCHAR (200)  NULL,
    [IncludeDismissAction] BIT             NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_Messages] PRIMARY KEY CLUSTERED ([MessageID] ASC),
    CONSTRAINT [FK_dnn_CoreMessaging_Messages_dnn_CoreMessaging_NotificationTypes] FOREIGN KEY ([NotificationTypeID]) REFERENCES [dbo].[dnn_CoreMessaging_NotificationTypes] ([NotificationTypeID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_CoreMessaging_Messages_SenderUserID]
    ON [dbo].[dnn_CoreMessaging_Messages]([SenderUserID] ASC, [CreatedOnDate] DESC);

