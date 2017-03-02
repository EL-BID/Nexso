CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalCategoryItems] (
    [PortalID]   INT NOT NULL,
    [CategoryID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalCategoryItems] PRIMARY KEY CLUSTERED ([PortalID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalCategoryItems_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalCategoryItems_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

