CREATE TABLE [dbo].[dnn_CoreMessaging_NotificationTypeActions] (
    [NotificationTypeActionID] INT            IDENTITY (1, 1) NOT NULL,
    [NotificationTypeID]       INT            NOT NULL,
    [NameResourceKey]          NVARCHAR (100) NOT NULL,
    [DescriptionResourceKey]   NVARCHAR (100) NULL,
    [ConfirmResourceKey]       NVARCHAR (100) NULL,
    [Order]                    INT            NOT NULL,
    [APICall]                  NVARCHAR (500) NOT NULL,
    [CreatedByUserID]          INT            NULL,
    [CreatedOnDate]            DATETIME       NULL,
    [LastModifiedByUserID]     INT            NULL,
    [LastModifiedOnDate]       DATETIME       NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_NotificationTypeActions] PRIMARY KEY CLUSTERED ([NotificationTypeActionID] ASC),
    CONSTRAINT [FK_dnn_CoreMessaging_NotificationTypeActions_dnn_CoreMessaging_NotificationTypes] FOREIGN KEY ([NotificationTypeID]) REFERENCES [dbo].[dnn_CoreMessaging_NotificationTypes] ([NotificationTypeID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_CoreMessaging_NotificationTypeActions]
    ON [dbo].[dnn_CoreMessaging_NotificationTypeActions]([NotificationTypeID] ASC);

