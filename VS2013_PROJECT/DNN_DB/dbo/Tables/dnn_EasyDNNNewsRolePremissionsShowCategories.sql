CREATE TABLE [dbo].[dnn_EasyDNNNewsRolePremissionsShowCategories] (
    [PremissionSettingsID] INT NOT NULL,
    [CategoryID]           INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsRolePremissionsShowCategories] PRIMARY KEY CLUSTERED ([PremissionSettingsID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsRolePremissionsAddToCategories_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsRolePremissionsAddToCategories_EasyDNNNewsRolePremissionSettings] FOREIGN KEY ([PremissionSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsRolePremissionSettings] ([PremissionSettingsID]) ON DELETE CASCADE
);

