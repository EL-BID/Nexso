CREATE TABLE [dbo].[dnn_Roles] (
    [RoleID]               INT             IDENTITY (0, 1) NOT NULL,
    [PortalID]             INT             NULL,
    [RoleName]             NVARCHAR (50)   NOT NULL,
    [Description]          NVARCHAR (1000) NULL,
    [ServiceFee]           MONEY           CONSTRAINT [DF_dnn_Roles_ServiceFee] DEFAULT ((0)) NULL,
    [BillingFrequency]     CHAR (1)        NULL,
    [TrialPeriod]          INT             NULL,
    [TrialFrequency]       CHAR (1)        NULL,
    [BillingPeriod]        INT             NULL,
    [TrialFee]             MONEY           NULL,
    [IsPublic]             BIT             CONSTRAINT [DF_dnn_Roles_IsPublic] DEFAULT ((0)) NOT NULL,
    [AutoAssignment]       BIT             CONSTRAINT [DF_dnn_Roles_AutoAssignment] DEFAULT ((0)) NOT NULL,
    [RoleGroupID]          INT             NULL,
    [RSVPCode]             NVARCHAR (50)   NULL,
    [IconFile]             NVARCHAR (100)  NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    [Status]               INT             CONSTRAINT [DF_dnn_Roles_Status] DEFAULT ((1)) NOT NULL,
    [SecurityMode]         INT             CONSTRAINT [DF_dnn_Roles_SecurityMode] DEFAULT ((0)) NOT NULL,
    [IsSystemRole]         BIT             CONSTRAINT [DF_dnn_Roles_IsSystemRole] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_Roles] PRIMARY KEY CLUSTERED ([RoleID] ASC),
    CONSTRAINT [FK_dnn_Roles_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Roles_dnn_RoleGroups] FOREIGN KEY ([RoleGroupID]) REFERENCES [dbo].[dnn_RoleGroups] ([RoleGroupID]),
    CONSTRAINT [IX_dnn_RoleName] UNIQUE NONCLUSTERED ([PortalID] ASC, [RoleName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Roles]
    ON [dbo].[dnn_Roles]([BillingFrequency] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Roles_RoleGroup]
    ON [dbo].[dnn_Roles]([RoleGroupID] ASC, [RoleName] ASC)
    INCLUDE([RoleID]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Roles_RoleName]
    ON [dbo].[dnn_Roles]([PortalID] ASC, [RoleName] ASC)
    INCLUDE([RoleID]);

