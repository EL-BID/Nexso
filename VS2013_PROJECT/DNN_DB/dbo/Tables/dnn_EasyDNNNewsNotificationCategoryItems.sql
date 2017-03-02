CREATE TABLE [dbo].[dnn_EasyDNNNewsNotificationCategoryItems] (
    [CategoryID] INT NOT NULL,
    [UserID]     INT NULL,
    [RoleID]     INT NULL,
    CONSTRAINT [FK_dnn_EasyDNNNewsNotificationCategoryItems_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsNotificationCategoryItems_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsNotificationCategoryItems_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsNotificationCategoryItems] UNIQUE CLUSTERED ([CategoryID] ASC, [UserID] ASC, [RoleID] ASC)
);

