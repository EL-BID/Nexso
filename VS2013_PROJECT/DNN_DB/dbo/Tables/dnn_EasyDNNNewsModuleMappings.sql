CREATE TABLE [dbo].[dnn_EasyDNNNewsModuleMappings] (
    [PortalID] INT NOT NULL,
    [oldID]    INT NOT NULL,
    [newID]    INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsModuleMappings] PRIMARY KEY CLUSTERED ([PortalID] ASC, [oldID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsModuleMappings_Modules] FOREIGN KEY ([newID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

