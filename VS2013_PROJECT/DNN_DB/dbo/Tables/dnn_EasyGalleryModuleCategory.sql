CREATE TABLE [dbo].[dnn_EasyGalleryModuleCategory] (
    [ModuleID]   INT NOT NULL,
    [CategoryID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryModuleCategory] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [CategoryID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryModuleCategory_dnn_EasyGalleryCategory] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyGalleryCategory] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryModuleCategory_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

