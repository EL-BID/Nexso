﻿CREATE TABLE [dbo].[dnn_TabPermission] (
    [TabPermissionID]      INT      IDENTITY (1, 1) NOT NULL,
    [TabID]                INT      NOT NULL,
    [PermissionID]         INT      NOT NULL,
    [AllowAccess]          BIT      NOT NULL,
    [RoleID]               INT      NULL,
    [UserID]               INT      NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    CONSTRAINT [PK_dnn_TabPermission] PRIMARY KEY CLUSTERED ([TabPermissionID] ASC),
    CONSTRAINT [FK_dnn_TabPermission_dnn_Permission] FOREIGN KEY ([PermissionID]) REFERENCES [dbo].[dnn_Permission] ([PermissionID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_TabPermission_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]),
    CONSTRAINT [FK_dnn_TabPermission_dnn_Tabs] FOREIGN KEY ([TabID]) REFERENCES [dbo].[dnn_Tabs] ([TabID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_TabPermission_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_TabPermission_Permission]
    ON [dbo].[dnn_TabPermission]([PermissionID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_TabPermission_Roles]
    ON [dbo].[dnn_TabPermission]([RoleID] ASC, [TabID] ASC, [PermissionID] ASC)
    INCLUDE([AllowAccess]) WHERE ([RoleID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_TabPermission_Tabs]
    ON [dbo].[dnn_TabPermission]([TabID] ASC, [PermissionID] ASC, [RoleID] ASC, [UserID] ASC)
    INCLUDE([AllowAccess]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_TabPermission_Users]
    ON [dbo].[dnn_TabPermission]([UserID] ASC, [TabID] ASC, [PermissionID] ASC)
    INCLUDE([AllowAccess]) WHERE ([UserID] IS NOT NULL);

