CREATE TABLE [dbo].[dnn_EasyGalleryCategoryRoleUserPermissions] (
    [PermissionID] INT IDENTITY (1, 1) NOT NULL,
    [CategoryID]   INT NOT NULL,
    [UserID]       INT NULL,
    [RoleID]       INT NULL,
    [View]         BIT NOT NULL,
    [Edit]         BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryCategoryRoleUserPermissions] PRIMARY KEY CLUSTERED ([PermissionID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryCategoryRoleUserPermissions_dnn_EasyGalleryCategory] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyGalleryCategory] ([CategoryID]) ON DELETE CASCADE
);

