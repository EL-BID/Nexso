CREATE TABLE [dbo].[dnn_EasyDNNNewsEventPostPortalSettings] (
    [PostSettingsID] INT NOT NULL,
    [PortalID]       INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventPostPortalSettings] PRIMARY KEY CLUSTERED ([PostSettingsID] ASC, [PortalID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostPortalSettings_EasyDNNNewsEventPostSettings] FOREIGN KEY ([PostSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventPostSettings] ([Id]) ON DELETE CASCADE
);

