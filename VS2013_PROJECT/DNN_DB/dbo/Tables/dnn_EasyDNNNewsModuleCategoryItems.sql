CREATE TABLE [dbo].[dnn_EasyDNNNewsModuleCategoryItems] (
    [ModuleID]   INT NOT NULL,
    [CategoryID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsModuleCategoryItems] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsModuleCategory_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE
);

