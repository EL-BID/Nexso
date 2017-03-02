CREATE TABLE [dbo].[dnn_Tabs] (
    [TabID]                INT              IDENTITY (0, 1) NOT NULL,
    [TabOrder]             INT              CONSTRAINT [DF_dnn_Tabs_TabOrder] DEFAULT ((0)) NOT NULL,
    [PortalID]             INT              NULL,
    [TabName]              NVARCHAR (200)   NOT NULL,
    [IsVisible]            BIT              CONSTRAINT [DF_dnn_Tabs_IsVisible] DEFAULT ((1)) NOT NULL,
    [ParentId]             INT              NULL,
    [IconFile]             NVARCHAR (100)   NULL,
    [DisableLink]          BIT              CONSTRAINT [DF_dnn_Tabs_DisableLink] DEFAULT ((0)) NOT NULL,
    [Title]                NVARCHAR (200)   NULL,
    [Description]          NVARCHAR (500)   NULL,
    [KeyWords]             NVARCHAR (500)   NULL,
    [IsDeleted]            BIT              CONSTRAINT [DF_dnn_Tabs_IsDeleted] DEFAULT ((0)) NOT NULL,
    [Url]                  NVARCHAR (255)   NULL,
    [SkinSrc]              NVARCHAR (200)   NULL,
    [ContainerSrc]         NVARCHAR (200)   NULL,
    [StartDate]            DATETIME         NULL,
    [EndDate]              DATETIME         NULL,
    [RefreshInterval]      INT              NULL,
    [PageHeadText]         NVARCHAR (MAX)   NULL,
    [IsSecure]             BIT              CONSTRAINT [DF_dnn_Tabs_IsSecure] DEFAULT ((0)) NOT NULL,
    [PermanentRedirect]    BIT              CONSTRAINT [DF_dnn_Tabs_PermanentRedirect] DEFAULT ((0)) NOT NULL,
    [SiteMapPriority]      FLOAT (53)       CONSTRAINT [DF_dnn_Tabs_SiteMapPriority] DEFAULT ((0.5)) NOT NULL,
    [CreatedByUserID]      INT              NULL,
    [CreatedOnDate]        DATETIME         NULL,
    [LastModifiedByUserID] INT              NULL,
    [LastModifiedOnDate]   DATETIME         NULL,
    [IconFileLarge]        NVARCHAR (100)   NULL,
    [CultureCode]          NVARCHAR (10)    NULL,
    [ContentItemID]        INT              NULL,
    [UniqueId]             UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Tabs_Guid] DEFAULT (newid()) NOT NULL,
    [VersionGuid]          UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Tabs_VersionGuid] DEFAULT (newid()) NOT NULL,
    [DefaultLanguageGuid]  UNIQUEIDENTIFIER NULL,
    [LocalizedVersionGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Tabs_LocalizedVersionGuid] DEFAULT (newid()) NOT NULL,
    [Level]                INT              CONSTRAINT [DF__dnn_Tabs__Level__526429B0] DEFAULT ((0)) NOT NULL,
    [TabPath]              NVARCHAR (255)   CONSTRAINT [DF__dnn_Tabs__TabPat__53584DE9] DEFAULT ('') NOT NULL,
    [HasBeenPublished]     BIT              CONSTRAINT [DF_Tabs_HasBeenPublished] DEFAULT ((0)) NOT NULL,
    [IsSystem]             BIT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_Tabs] PRIMARY KEY CLUSTERED ([TabID] ASC),
    CONSTRAINT [FK_dnn_Tabs_dnn_ContentItems] FOREIGN KEY ([ContentItemID]) REFERENCES [dbo].[dnn_ContentItems] ([ContentItemID]),
    CONSTRAINT [FK_dnn_Tabs_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Tabs_dnn_Tabs] FOREIGN KEY ([ParentId]) REFERENCES [dbo].[dnn_Tabs] ([TabID]),
    CONSTRAINT [IX_dnn_Tabs_UniqueId] UNIQUE NONCLUSTERED ([UniqueId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Tabs_ContentID]
    ON [dbo].[dnn_Tabs]([ContentItemID] ASC)
    INCLUDE([TabID], [TabName], [Title], [IsVisible], [IsDeleted], [UniqueId], [CultureCode]) WHERE ([ContentItemId] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Tabs_ParentId_IsDeleted]
    ON [dbo].[dnn_Tabs]([ParentId] ASC, [IsDeleted] ASC)
    INCLUDE([CreatedOnDate]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Tabs_PortalLevelParentOrder]
    ON [dbo].[dnn_Tabs]([PortalID] ASC, [Level] ASC, [ParentId] ASC, [TabOrder] ASC, [IsDeleted] ASC)
    INCLUDE([TabID], [TabName], [IsVisible], [IconFile], [DisableLink], [Title], [Description], [KeyWords], [Url], [SkinSrc], [ContainerSrc], [StartDate], [EndDate], [RefreshInterval], [PageHeadText], [IsSecure], [PermanentRedirect], [SiteMapPriority], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate], [IconFileLarge], [CultureCode], [ContentItemID], [UniqueId], [VersionGuid], [DefaultLanguageGuid], [LocalizedVersionGuid], [TabPath]);

