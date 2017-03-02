CREATE TABLE [dbo].[dnn_CoreMessaging_NotificationTypes] (
    [NotificationTypeID]   INT             IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (100)  NOT NULL,
    [Description]          NVARCHAR (2000) NULL,
    [TTL]                  INT             NULL,
    [DesktopModuleID]      INT             NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    [IsTask]               BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_NotificationTypes] PRIMARY KEY CLUSTERED ([NotificationTypeID] ASC),
    CONSTRAINT [FK_dnn_CoreMessaging_NotificationTypes_dnn_DesktopModules] FOREIGN KEY ([DesktopModuleID]) REFERENCES [dbo].[dnn_DesktopModules] ([DesktopModuleID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_CoreMessaging_NotificationTypes]
    ON [dbo].[dnn_CoreMessaging_NotificationTypes]([Name] ASC);

