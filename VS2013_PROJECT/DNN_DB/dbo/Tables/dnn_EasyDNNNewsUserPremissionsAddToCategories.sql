CREATE TABLE [dbo].[dnn_EasyDNNNewsUserPremissionsAddToCategories] (
    [PremissionSettingsID] INT NOT NULL,
    [CategoryID]           INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsUserPremissionsAddToCategories] PRIMARY KEY CLUSTERED ([PremissionSettingsID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsUserPremissionsAddToCategories_EasyDNNNewsCategoryList1] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsUserPremissionsAddToCategories_EasyDNNNewsUserPremissionSettings1] FOREIGN KEY ([PremissionSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsUserPremissionSettings] ([PremissionSettingsID]) ON DELETE CASCADE
);

