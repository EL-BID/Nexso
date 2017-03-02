CREATE TABLE [dbo].[dnn_Portals] (
    [PortalID]             INT              IDENTITY (0, 1) NOT NULL,
    [ExpiryDate]           DATETIME         NULL,
    [UserRegistration]     INT              CONSTRAINT [DF_dnn_Portals_UserRegistration] DEFAULT ((0)) NOT NULL,
    [BannerAdvertising]    INT              CONSTRAINT [DF_dnn_Portals_BannerAdvertising] DEFAULT ((0)) NOT NULL,
    [AdministratorId]      INT              NULL,
    [Currency]             CHAR (3)         NULL,
    [HostFee]              MONEY            CONSTRAINT [DF_dnn_Portals_HostFee] DEFAULT ((0)) NOT NULL,
    [HostSpace]            INT              CONSTRAINT [DF_dnn_Portals_HostSpace] DEFAULT ((0)) NOT NULL,
    [AdministratorRoleId]  INT              NULL,
    [RegisteredRoleId]     INT              NULL,
    [GUID]                 UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Portals_GUID] DEFAULT (newid()) NOT NULL,
    [PaymentProcessor]     NVARCHAR (50)    NULL,
    [ProcessorUserId]      NVARCHAR (50)    NULL,
    [ProcessorPassword]    NVARCHAR (50)    NULL,
    [SiteLogHistory]       INT              NULL,
    [DefaultLanguage]      NVARCHAR (10)    CONSTRAINT [DF_dnn_Portals_DefaultLanguage] DEFAULT ('en-US') NOT NULL,
    [TimezoneOffset]       INT              CONSTRAINT [DF_dnn_Portals_TimezoneOffset] DEFAULT ((-8)) NOT NULL,
    [HomeDirectory]        VARCHAR (100)    CONSTRAINT [DF_dnn_Portals_HomeDirectory] DEFAULT ('') NOT NULL,
    [PageQuota]            INT              CONSTRAINT [DF_dnn_Portals_PageQuota] DEFAULT ((0)) NOT NULL,
    [UserQuota]            INT              CONSTRAINT [DF_dnn_Portals_UserQuota] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT              NULL,
    [CreatedOnDate]        DATETIME         NULL,
    [LastModifiedByUserID] INT              NULL,
    [LastModifiedOnDate]   DATETIME         NULL,
    [PortalGroupID]        INT              NULL,
    CONSTRAINT [PK_dnn_Portals] PRIMARY KEY CLUSTERED ([PortalID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Portals_AdministratorId]
    ON [dbo].[dnn_Portals]([AdministratorId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Portals_DefaultLanguage]
    ON [dbo].[dnn_Portals]([DefaultLanguage] ASC);

