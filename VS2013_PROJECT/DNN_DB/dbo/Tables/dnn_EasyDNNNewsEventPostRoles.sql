CREATE TABLE [dbo].[dnn_EasyDNNNewsEventPostRoles] (
    [PostSettingsID] INT NOT NULL,
    [RoleID]         INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventPostRoles] PRIMARY KEY CLUSTERED ([PostSettingsID] ASC, [RoleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostRoles_EasyDNNNewsEventPostSettings] FOREIGN KEY ([PostSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventPostSettings] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostRoles_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID])
);

