CREATE TABLE [dbo].[UserNotificationConnections] (
    [UserNotificationConnection] UNIQUEIDENTIFIER NOT NULL,
    [NotificationId]             UNIQUEIDENTIFIER NOT NULL,
    [UserId]                     INT              NOT NULL,
    [Rol]                        VARCHAR (50)     NOT NULL,
    [Tag]                        VARCHAR (500)    NULL,
    CONSTRAINT [PK_UserNotificationConnections] PRIMARY KEY CLUSTERED ([UserNotificationConnection] ASC),
    CONSTRAINT [FK_UserNotificationConnections_Notifications] FOREIGN KEY ([NotificationId]) REFERENCES [dbo].[Notifications] ([NotificationId]),
    CONSTRAINT [FK_UserNotificationConnections_UserProperties] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[UserNotificationConnections] NOCHECK CONSTRAINT [FK_UserNotificationConnections_Notifications];


GO
ALTER TABLE [dbo].[UserNotificationConnections] NOCHECK CONSTRAINT [FK_UserNotificationConnections_UserProperties];



