CREATE TABLE [dbo].[dnn_PortalDesktopModules] (
    [PortalDesktopModuleID] INT      IDENTITY (1, 1) NOT NULL,
    [PortalID]              INT      NOT NULL,
    [DesktopModuleID]       INT      NOT NULL,
    [CreatedByUserID]       INT      NULL,
    [CreatedOnDate]         DATETIME NULL,
    [LastModifiedByUserID]  INT      NULL,
    [LastModifiedOnDate]    DATETIME NULL,
    CONSTRAINT [PK_dnn_PortalDesktopModules] PRIMARY KEY CLUSTERED ([PortalDesktopModuleID] ASC),
    CONSTRAINT [FK_dnn_PortalDesktopModules_dnn_DesktopModules] FOREIGN KEY ([DesktopModuleID]) REFERENCES [dbo].[dnn_DesktopModules] ([DesktopModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_PortalDesktopModules_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_PortalDesktopModules] UNIQUE NONCLUSTERED ([PortalID] ASC, [DesktopModuleID] ASC)
);

