CREATE TABLE [dbo].[dnn_CoreMessaging_SubscriptionTypes] (
    [SubscriptionTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [SubscriptionName]   NVARCHAR (50) NOT NULL,
    [FriendlyName]       NVARCHAR (50) NOT NULL,
    [DesktopModuleId]    INT           NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_SubscriptionTypes] PRIMARY KEY CLUSTERED ([SubscriptionTypeId] ASC)
);

