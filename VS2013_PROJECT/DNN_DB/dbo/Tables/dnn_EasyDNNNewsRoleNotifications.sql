CREATE TABLE [dbo].[dnn_EasyDNNNewsRoleNotifications] (
    [RoleID]              INT NOT NULL,
    [NewArticle]          BIT NOT NULL,
    [NewEvent]            BIT NOT NULL,
    [EditArticle]         BIT NOT NULL,
    [ApproveArticle]      BIT NOT NULL,
    [NewComment]          BIT NOT NULL,
    [ApproveComment]      BIT NOT NULL,
    [SendToAllCategories] BIT CONSTRAINT [DF_dnn_EasyDNNNewsRoleNotifications_SendToAllCategories] DEFAULT ((1)) NOT NULL,
    [EventRegistration]   BIT CONSTRAINT [DF_dnn_EasyDNNNewsRoleNotifications_EventRegistrations] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsRoleNotifications] PRIMARY KEY CLUSTERED ([RoleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsRoleNotifications_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

