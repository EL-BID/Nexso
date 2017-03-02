CREATE TABLE [dbo].[dnn_EasyDNNNewsEventPostUsers] (
    [PostSettingsID] INT NOT NULL,
    [UserID]         INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventPostUsers] PRIMARY KEY CLUSTERED ([PostSettingsID] ASC, [UserID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostUsers_EasyDNNNewsEventPostSettings] FOREIGN KEY ([PostSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventPostSettings] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostUsers_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

