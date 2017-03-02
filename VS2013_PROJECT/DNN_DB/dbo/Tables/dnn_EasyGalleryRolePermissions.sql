CREATE TABLE [dbo].[dnn_EasyGalleryRolePermissions] (
    [RolePermissionID] INT IDENTITY (1, 1) NOT NULL,
    [RoleID]           INT NULL,
    [ModuleID]         INT NOT NULL,
    [ShowComments]     BIT NOT NULL,
    [AllowToComment]   BIT NOT NULL,
    [CommentEditing]   BIT NOT NULL,
    [CommentDeleting]  BIT NOT NULL,
    [ShowRating]       BIT NOT NULL,
    [AllowToRate]      BIT NOT NULL,
    [AllowToDownload]  BIT NOT NULL,
    [AllowToLike]      BIT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryRolePermissions] PRIMARY KEY CLUSTERED ([RolePermissionID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryRolePermissions_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryRolePermissions_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE
);

