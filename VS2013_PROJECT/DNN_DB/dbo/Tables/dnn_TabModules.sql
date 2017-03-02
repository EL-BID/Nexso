CREATE TABLE [dbo].[dnn_TabModules] (
    [TabModuleID]          INT              IDENTITY (1, 1) NOT NULL,
    [TabID]                INT              NOT NULL,
    [ModuleID]             INT              NOT NULL,
    [PaneName]             NVARCHAR (50)    NOT NULL,
    [ModuleOrder]          INT              NOT NULL,
    [CacheTime]            INT              NOT NULL,
    [Alignment]            NVARCHAR (10)    NULL,
    [Color]                NVARCHAR (20)    NULL,
    [Border]               NVARCHAR (1)     NULL,
    [IconFile]             NVARCHAR (100)   NULL,
    [Visibility]           INT              NOT NULL,
    [ContainerSrc]         NVARCHAR (200)   NULL,
    [DisplayTitle]         BIT              CONSTRAINT [DF_dnn_TabModules_DisplayTitle] DEFAULT ((1)) NOT NULL,
    [DisplayPrint]         BIT              CONSTRAINT [DF_dnn_TabModules_DisplayPrint] DEFAULT ((1)) NOT NULL,
    [DisplaySyndicate]     BIT              CONSTRAINT [DF_dnn_TabModules_DisplaySyndicate] DEFAULT ((1)) NOT NULL,
    [IsWebSlice]           BIT              CONSTRAINT [DF_dnn_abModules_IsWebSlice] DEFAULT ((0)) NOT NULL,
    [WebSliceTitle]        NVARCHAR (256)   NULL,
    [WebSliceExpiryDate]   DATETIME         NULL,
    [WebSliceTTL]          INT              NULL,
    [CreatedByUserID]      INT              NULL,
    [CreatedOnDate]        DATETIME         CONSTRAINT [DF_dnn_TabModules_CreatedOnDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserID] INT              NULL,
    [LastModifiedOnDate]   DATETIME         CONSTRAINT [DF_dnn_TabModules_LastModifiedOnDate] DEFAULT (getdate()) NULL,
    [IsDeleted]            BIT              CONSTRAINT [DF_dnn_TabModules_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CacheMethod]          VARCHAR (50)     NULL,
    [ModuleTitle]          NVARCHAR (256)   NULL,
    [Header]               NVARCHAR (MAX)   NULL,
    [Footer]               NVARCHAR (MAX)   NULL,
    [CultureCode]          NVARCHAR (10)    NULL,
    [UniqueId]             UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_TabModules_Guid] DEFAULT (newid()) NOT NULL,
    [VersionGuid]          UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_TabModules_VersionGuid] DEFAULT (newid()) NOT NULL,
    [DefaultLanguageGuid]  UNIQUEIDENTIFIER NULL,
    [LocalizedVersionGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_TabModules_LocalizedVersionGuid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_dnn_TabModules] PRIMARY KEY CLUSTERED ([TabModuleID] ASC),
    CONSTRAINT [FK_dnn_TabModules_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_TabModules_dnn_Tabs] FOREIGN KEY ([TabID]) REFERENCES [dbo].[dnn_Tabs] ([TabID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_TabModules_UniqueId] UNIQUE NONCLUSTERED ([UniqueId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_TabModules_ModuleID]
    ON [dbo].[dnn_TabModules]([ModuleID] ASC, [TabID] ASC)
    INCLUDE([IsDeleted], [CultureCode], [ModuleTitle]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_TabModules_ModuleOrder]
    ON [dbo].[dnn_TabModules]([TabID] ASC, [PaneName] ASC, [ModuleOrder] ASC)
    INCLUDE([TabModuleID], [ModuleID], [CacheTime], [Alignment], [Color], [Border], [IconFile], [Visibility], [ContainerSrc], [DisplayTitle], [DisplayPrint], [DisplaySyndicate], [IsWebSlice], [WebSliceTitle], [WebSliceExpiryDate], [WebSliceTTL], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate], [IsDeleted], [CacheMethod], [ModuleTitle], [Header], [Footer], [CultureCode], [UniqueId], [VersionGuid], [DefaultLanguageGuid], [LocalizedVersionGuid]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_TabModules_TabID]
    ON [dbo].[dnn_TabModules]([TabID] ASC, [ModuleID] ASC)
    INCLUDE([IsDeleted], [CultureCode], [ModuleTitle]);

