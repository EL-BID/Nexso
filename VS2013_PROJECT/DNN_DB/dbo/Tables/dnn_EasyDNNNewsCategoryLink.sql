CREATE TABLE [dbo].[dnn_EasyDNNNewsCategoryLink] (
    [SourceModuleID] INT NOT NULL,
    [CategoryID]     INT NOT NULL,
    [NewsModuleID]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsCategoryLink] PRIMARY KEY CLUSTERED ([SourceModuleID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsCategoryLink_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsCategoryLink_Modules] FOREIGN KEY ([SourceModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

