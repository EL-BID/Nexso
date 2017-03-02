CREATE TABLE [dbo].[dnn_EasyDNNNewsFilterByTagID] (
    [FilterModuleID] INT NOT NULL,
    [TagID]          INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsFilterByTagID] PRIMARY KEY CLUSTERED ([FilterModuleID] ASC, [TagID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsFilterByTagID_EasyDNNNewsNewTags] FOREIGN KEY ([TagID]) REFERENCES [dbo].[dnn_EasyDNNNewsNewTags] ([TagID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsFilterByTagID_Modules] FOREIGN KEY ([FilterModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

