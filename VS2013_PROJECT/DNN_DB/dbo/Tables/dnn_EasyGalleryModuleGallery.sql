CREATE TABLE [dbo].[dnn_EasyGalleryModuleGallery] (
    [ModuleID]  INT NOT NULL,
    [GalleryID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryModuleGallery] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [GalleryID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryModuleGallery_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryModuleGallery_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE
);

