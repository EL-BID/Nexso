CREATE TABLE [dbo].[dnn_EasyDNNNewsSearchCategoryFieldItems] (
    [ModuleID]         INT NOT NULL,
    [CategoryID]       INT NOT NULL,
    [FieldsTemplateID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsSearchCategoryFieldItems] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [CategoryID] ASC, [FieldsTemplateID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsSearchCategoryFieldItems_EasyDNNfieldsTemplate] FOREIGN KEY ([FieldsTemplateID]) REFERENCES [dbo].[dnn_EasyDNNfieldsTemplate] ([FieldsTemplateID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsSearchCategoryFieldItems_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsSearchCategoryFieldItems_EasyDNNNewsSearchSettings] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_EasyDNNNewsSearchSettings] ([ModuleID]) ON DELETE CASCADE
);

