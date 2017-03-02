CREATE TABLE [dbo].[dnn_EasyDNNNewsModuleGroupItems] (
    [ModuleID] INT NOT NULL,
    [GroupID]  INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsModuleGroupItems] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [GroupID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsModuleGroupItems_EasyDNNNewsAuthorGroups] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[dnn_EasyDNNNewsAuthorGroups] ([GroupID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsModuleGroupItems_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

