CREATE TABLE [dbo].[dnn_PortalAlias] (
    [PortalAliasID]        INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT            NOT NULL,
    [HTTPAlias]            NVARCHAR (200) NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    [BrowserType]          NVARCHAR (10)  NULL,
    [Skin]                 NVARCHAR (100) NULL,
    [CultureCode]          NVARCHAR (10)  NULL,
    [IsPrimary]            BIT            CONSTRAINT [DF_dnn_PortalAlias_IsPrimary] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_PortalAlias] PRIMARY KEY CLUSTERED ([PortalAliasID] ASC),
    CONSTRAINT [FK_dnn_PortalAlias_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_PortalAlias] UNIQUE NONCLUSTERED ([HTTPAlias] ASC)
);

