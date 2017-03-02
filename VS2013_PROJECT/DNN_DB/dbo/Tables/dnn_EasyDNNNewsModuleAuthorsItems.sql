CREATE TABLE [dbo].[dnn_EasyDNNNewsModuleAuthorsItems] (
    [ModuleID] INT NOT NULL,
    [UserID]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsModuleAuthorsItems] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [UserID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsModuleAuthorsItems_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsModuleAuthorsItems_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

