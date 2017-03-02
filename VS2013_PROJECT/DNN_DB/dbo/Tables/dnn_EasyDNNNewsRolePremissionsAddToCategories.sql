CREATE TABLE [dbo].[dnn_EasyDNNNewsRolePremissionsAddToCategories] (
    [PremissionSettingsID] INT NOT NULL,
    [CategoryID]           INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsRolePremissionsAddToCategories] PRIMARY KEY CLUSTERED ([PremissionSettingsID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsRolePremissionsAddToCategories_EasyDNNNewsCategoryList1] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsRolePremissionsAddToCategories_EasyDNNNewsRolePremissionSettings1] FOREIGN KEY ([PremissionSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsRolePremissionSettings] ([PremissionSettingsID]) ON DELETE CASCADE
);

