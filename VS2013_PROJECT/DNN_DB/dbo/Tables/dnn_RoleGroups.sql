CREATE TABLE [dbo].[dnn_RoleGroups] (
    [RoleGroupID]          INT             IDENTITY (0, 1) NOT NULL,
    [PortalID]             INT             NOT NULL,
    [RoleGroupName]        NVARCHAR (50)   NOT NULL,
    [Description]          NVARCHAR (1000) NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    CONSTRAINT [PK_dnn_RoleGroups] PRIMARY KEY CLUSTERED ([RoleGroupID] ASC),
    CONSTRAINT [FK_dnn_RoleGroups_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_RoleGroupName] UNIQUE NONCLUSTERED ([PortalID] ASC, [RoleGroupName] ASC)
);

