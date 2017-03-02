CREATE TABLE [dbo].[dnn_CoreMessaging_Subscriptions] (
    [SubscriptionId]     INT            IDENTITY (1, 1) NOT NULL,
    [UserId]             INT            NOT NULL,
    [PortalId]           INT            NULL,
    [SubscriptionTypeId] INT            NOT NULL,
    [ObjectKey]          NVARCHAR (255) NULL,
    [ObjectData]         NVARCHAR (MAX) NULL,
    [Description]        NVARCHAR (255) NOT NULL,
    [CreatedOnDate]      DATETIME       NOT NULL,
    [ModuleId]           INT            NULL,
    [TabId]              INT            NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_Subscriptions] PRIMARY KEY CLUSTERED ([SubscriptionId] ASC),
    CONSTRAINT [FK_dnn_CoreMessaging_Subscriptions_dnn_Modules] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_dnn_CoreMessaging_Subscriptions_dnn_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_dnn_CoreMessaging_Subscriptions_dnn_Subscriptions_Type] FOREIGN KEY ([SubscriptionTypeId]) REFERENCES [dbo].[dnn_CoreMessaging_SubscriptionTypes] ([SubscriptionTypeId]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_dnn_CoreMessaging_Subscriptions_dnn_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE ON UPDATE CASCADE
);

