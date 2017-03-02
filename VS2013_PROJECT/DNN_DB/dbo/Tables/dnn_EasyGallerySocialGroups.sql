CREATE TABLE [dbo].[dnn_EasyGallerySocialGroups] (
    [GalleryID] INT NOT NULL,
    [RoleID]    INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGallerySocialGroups] PRIMARY KEY CLUSTERED ([GalleryID] ASC, [RoleID] ASC),
    CONSTRAINT [FK_dnn_EasyGallerySocialGroups_dnn_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGallerySocialGroups_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

