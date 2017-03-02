CREATE TABLE [dbo].[dnn_PortalGroups] (
    [PortalGroupID]          INT             IDENTITY (1, 1) NOT NULL,
    [MasterPortalID]         INT             NULL,
    [PortalGroupName]        NVARCHAR (100)  NULL,
    [PortalGroupDescription] NVARCHAR (2000) NULL,
    [AuthenticationDomain]   NVARCHAR (200)  NULL,
    [CreatedByUserID]        INT             NULL,
    [CreatedOnDate]          DATETIME        NULL,
    [LastModifiedByUserID]   INT             NULL,
    [LastModifiedOnDate]     DATETIME        NULL,
    CONSTRAINT [PK_dnn_PortalGroup] PRIMARY KEY CLUSTERED ([PortalGroupID] ASC)
);

