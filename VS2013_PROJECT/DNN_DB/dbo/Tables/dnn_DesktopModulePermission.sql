CREATE TABLE [dbo].[dnn_DesktopModulePermission] (
    [DesktopModulePermissionID] INT      IDENTITY (1, 1) NOT NULL,
    [PortalDesktopModuleID]     INT      NOT NULL,
    [PermissionID]              INT      NOT NULL,
    [AllowAccess]               BIT      NOT NULL,
    [RoleID]                    INT      NULL,
    [UserID]                    INT      NULL,
    [CreatedByUserID]           INT      NULL,
    [CreatedOnDate]             DATETIME NULL,
    [LastModifiedByUserID]      INT      NULL,
    [LastModifiedOnDate]        DATETIME NULL,
    CONSTRAINT [PK_dnn_DesktopModulePermission] PRIMARY KEY CLUSTERED ([DesktopModulePermissionID] ASC),
    CONSTRAINT [FK_dnn_DesktopModulePermission_dnn_Permission] FOREIGN KEY ([PermissionID]) REFERENCES [dbo].[dnn_Permission] ([PermissionID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_DesktopModulePermission_dnn_PortalDesktopModules] FOREIGN KEY ([PortalDesktopModuleID]) REFERENCES [dbo].[dnn_PortalDesktopModules] ([PortalDesktopModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_DesktopModulePermission_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]),
    CONSTRAINT [FK_dnn_DesktopModulePermission_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_DesktopModulePermission_DesktopModules]
    ON [dbo].[dnn_DesktopModulePermission]([PortalDesktopModuleID] ASC, [PermissionID] ASC, [RoleID] ASC, [UserID] ASC)
    INCLUDE([AllowAccess]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_DesktopModulePermission_Roles]
    ON [dbo].[dnn_DesktopModulePermission]([RoleID] ASC, [PortalDesktopModuleID] ASC, [PermissionID] ASC)
    INCLUDE([AllowAccess]) WHERE ([RoleID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_DesktopModulePermission_Users]
    ON [dbo].[dnn_DesktopModulePermission]([UserID] ASC, [PortalDesktopModuleID] ASC, [PermissionID] ASC)
    INCLUDE([AllowAccess]) WHERE ([UserID] IS NOT NULL);

