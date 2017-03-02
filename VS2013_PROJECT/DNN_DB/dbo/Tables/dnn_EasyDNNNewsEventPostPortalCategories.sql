CREATE TABLE [dbo].[dnn_EasyDNNNewsEventPostPortalCategories] (
    [PortalID]   INT NOT NULL,
    [CategoryID] INT NOT NULL,
    [ModuleID]   INT NOT NULL,
    [TabID]      INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventPostPortalCategories] PRIMARY KEY CLUSTERED ([PortalID] ASC, [CategoryID] ASC, [ModuleID] ASC, [TabID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostPortalCategories_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostPortalCategories_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostPortalCategories_Tabs] FOREIGN KEY ([TabID]) REFERENCES [dbo].[dnn_Tabs] ([TabID]) ON DELETE CASCADE
);

