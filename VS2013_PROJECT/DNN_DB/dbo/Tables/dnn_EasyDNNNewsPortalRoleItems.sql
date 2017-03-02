CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalRoleItems] (
    [PortalID] INT NOT NULL,
    [RoleID]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalRoleItems] PRIMARY KEY CLUSTERED ([RoleID] ASC, [PortalID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalRoleItems_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalRoleItems_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

