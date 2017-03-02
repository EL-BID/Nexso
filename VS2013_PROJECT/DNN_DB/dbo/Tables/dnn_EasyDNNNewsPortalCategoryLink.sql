CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalCategoryLink] (
    [SourcePortalID] INT NOT NULL,
    [CategoryID]     INT NOT NULL,
    [NewsModuleID]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalCategoryLink] PRIMARY KEY CLUSTERED ([SourcePortalID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalCategoryLink_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalCategoryLink_Modules] FOREIGN KEY ([NewsModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalCategoryLink_Portals] FOREIGN KEY ([SourcePortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

