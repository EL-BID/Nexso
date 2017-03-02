CREATE TABLE [dbo].[dnn_FolderPermission] (
    [FolderPermissionID]   INT      IDENTITY (1, 1) NOT NULL,
    [FolderID]             INT      NOT NULL,
    [PermissionID]         INT      NOT NULL,
    [AllowAccess]          BIT      NOT NULL,
    [RoleID]               INT      NULL,
    [UserID]               INT      NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    CONSTRAINT [PK_dnn_FolderPermission] PRIMARY KEY CLUSTERED ([FolderPermissionID] ASC),
    CONSTRAINT [FK_dnn_FolderPermission_dnn_Folders] FOREIGN KEY ([FolderID]) REFERENCES [dbo].[dnn_Folders] ([FolderID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_FolderPermission_dnn_Permission] FOREIGN KEY ([PermissionID]) REFERENCES [dbo].[dnn_Permission] ([PermissionID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_FolderPermission_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]),
    CONSTRAINT [FK_dnn_FolderPermission_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_FolderPermission_Folders]
    ON [dbo].[dnn_FolderPermission]([FolderID] ASC, [PermissionID] ASC, [RoleID] ASC, [UserID] ASC)
    INCLUDE([AllowAccess]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_FolderPermission_Modules]
    ON [dbo].[dnn_FolderPermission]([FolderID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_FolderPermission_Permission]
    ON [dbo].[dnn_FolderPermission]([PermissionID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_FolderPermission_Roles]
    ON [dbo].[dnn_FolderPermission]([RoleID] ASC, [FolderID] ASC, [PermissionID] ASC)
    INCLUDE([AllowAccess]) WHERE ([RoleID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_FolderPermission_Users]
    ON [dbo].[dnn_FolderPermission]([UserID] ASC, [FolderID] ASC, [PermissionID] ASC)
    INCLUDE([AllowAccess]) WHERE ([UserID] IS NOT NULL);

