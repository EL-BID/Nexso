CREATE TABLE [dbo].[dnn_EasyDNNNewsUserNotifications] (
    [UserID]              INT NOT NULL,
    [PortalID]            INT NOT NULL,
    [NewArticle]          BIT NOT NULL,
    [NewEvent]            BIT NOT NULL,
    [EditArticle]         BIT NOT NULL,
    [ApproveArticle]      BIT NOT NULL,
    [NewComment]          BIT NOT NULL,
    [ApproveComment]      BIT NOT NULL,
    [SendToAllCategories] BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserNotifications_SendToAllCategories] DEFAULT ((1)) NOT NULL,
    [EventRegistration]   BIT CONSTRAINT [DF_dnn_EasyDNNNewsUserNotifications_EventRegistration] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsUserNotifications] PRIMARY KEY CLUSTERED ([UserID] ASC, [PortalID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsUserNotifications_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsUserNotifications_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

