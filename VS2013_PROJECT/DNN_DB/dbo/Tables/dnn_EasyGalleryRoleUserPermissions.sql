CREATE TABLE [dbo].[dnn_EasyGalleryRoleUserPermissions] (
    [PermissionID] INT IDENTITY (1, 1) NOT NULL,
    [GalleryID]    INT NOT NULL,
    [RoleID]       INT NULL,
    [UserID]       INT NULL,
    [View]         BIT NOT NULL,
    [Edit]         BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryRoleUserPermissions] PRIMARY KEY CLUSTERED ([PermissionID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryRoleUserPermissions_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryRoleUserPermissions_EasyGallery] FOREIGN KEY ([GalleryID]) REFERENCES [dbo].[dnn_EasyGallery] ([GalleryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryRoleUserPermissions_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

