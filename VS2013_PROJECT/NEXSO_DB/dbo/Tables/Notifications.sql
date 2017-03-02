CREATE TABLE [dbo].[Notifications] (
    [NotificationId] UNIQUEIDENTIFIER NOT NULL,
    [UserId]         INT              NOT NULL,
    [Code]           VARCHAR (50)     NOT NULL,
    [Created]        DATETIME         NOT NULL,
    [Read]           DATETIME         NULL,
    [Message]        VARCHAR (500)    NULL,
    [ToolTip]        VARCHAR (500)    NULL,
    [Tag]            VARCHAR (500)    NOT NULL,
    [Link]           VARCHAR (500)    NULL,
    [ObjectType]     VARCHAR (500)    NULL,
    CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED ([NotificationId] ASC),
    CONSTRAINT [FK_Notifications_UserProperties] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[Notifications] NOCHECK CONSTRAINT [FK_Notifications_UserProperties];



