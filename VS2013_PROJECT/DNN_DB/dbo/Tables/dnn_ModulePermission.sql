CREATE TABLE [dbo].[dnn_ModulePermission] (
    [ModulePermissionID]   INT      IDENTITY (1, 1) NOT NULL,
    [ModuleID]             INT      NOT NULL,
    [PermissionID]         INT      NOT NULL,
    [AllowAccess]          BIT      NOT NULL,
    [RoleID]               INT      NULL,
    [UserID]               INT      NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    [PortalID]             INT      NOT NULL,
    CONSTRAINT [PK_dnn_ModulePermission] PRIMARY KEY CLUSTERED ([ModulePermissionID] ASC),
    CONSTRAINT [FK_dnn_ModulePermission_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_ModulePermission_dnn_Permission] FOREIGN KEY ([PermissionID]) REFERENCES [dbo].[dnn_Permission] ([PermissionID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_ModulePermission_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]),
    CONSTRAINT [FK_dnn_ModulePermission_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ModulePermission_Modules]
    ON [dbo].[dnn_ModulePermission]([ModuleID] ASC, [PermissionID] ASC, [PortalID] ASC, [RoleID] ASC, [UserID] ASC)
    INCLUDE([AllowAccess]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ModulePermission_Permission]
    ON [dbo].[dnn_ModulePermission]([PermissionID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ModulePermission_Roles]
    ON [dbo].[dnn_ModulePermission]([RoleID] ASC, [ModuleID] ASC, [PermissionID] ASC, [PortalID] ASC)
    INCLUDE([AllowAccess]) WHERE ([RoleID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ModulePermission_Users]
    ON [dbo].[dnn_ModulePermission]([UserID] ASC, [ModuleID] ASC, [PermissionID] ASC, [PortalID] ASC)
    INCLUDE([AllowAccess]) WHERE ([UserID] IS NOT NULL);

