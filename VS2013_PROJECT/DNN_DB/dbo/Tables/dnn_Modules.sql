CREATE TABLE [dbo].[dnn_Modules] (
    [ModuleID]                  INT      IDENTITY (0, 1) NOT NULL,
    [ModuleDefID]               INT      NOT NULL,
    [AllTabs]                   BIT      CONSTRAINT [DF_dnn_Modules_AllTabs] DEFAULT ((0)) NOT NULL,
    [IsDeleted]                 BIT      CONSTRAINT [DF_dnn_Modules_IsDeleted] DEFAULT ((0)) NOT NULL,
    [InheritViewPermissions]    BIT      NULL,
    [StartDate]                 DATETIME NULL,
    [EndDate]                   DATETIME NULL,
    [PortalID]                  INT      NULL,
    [CreatedByUserID]           INT      NULL,
    [CreatedOnDate]             DATETIME CONSTRAINT [DF_dnn_Modules_CreatedOnDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserID]      INT      NULL,
    [LastModifiedOnDate]        DATETIME CONSTRAINT [DF_dnn_Modules_LastModifiedOnDate] DEFAULT (getdate()) NULL,
    [LastContentModifiedOnDate] DATETIME NULL,
    [ContentItemID]             INT      NULL,
    [IsShareable]               BIT      CONSTRAINT [DF_dnn_Modules_IsShareable] DEFAULT ((1)) NOT NULL,
    [IsShareableViewOnly]       BIT      CONSTRAINT [DF_dnn_Modules_IsShareableViewOnly] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_Modules] PRIMARY KEY CLUSTERED ([ModuleID] ASC),
    CONSTRAINT [FK_dnn_Modules_dnn_ContentItems] FOREIGN KEY ([ContentItemID]) REFERENCES [dbo].[dnn_ContentItems] ([ContentItemID]),
    CONSTRAINT [FK_dnn_Modules_dnn_ModuleDefinitions] FOREIGN KEY ([ModuleDefID]) REFERENCES [dbo].[dnn_ModuleDefinitions] ([ModuleDefID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Modules_ModuleDefId]
    ON [dbo].[dnn_Modules]([ModuleDefID] ASC)
    INCLUDE([ModuleID]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Modules_PortalId]
    ON [dbo].[dnn_Modules]([PortalID] ASC);

