CREATE TABLE [dbo].[dnn_Lists] (
    [EntryID]              INT            IDENTITY (1, 1) NOT NULL,
    [ListName]             NVARCHAR (50)  NOT NULL,
    [Value]                NVARCHAR (100) NOT NULL,
    [Text]                 NVARCHAR (150) NOT NULL,
    [ParentID]             INT            CONSTRAINT [DF_dnn_Lists_ParentID] DEFAULT ((0)) NOT NULL,
    [Level]                INT            CONSTRAINT [DF_dnn_Lists_Level] DEFAULT ((0)) NOT NULL,
    [SortOrder]            INT            CONSTRAINT [DF_dnn_Lists_SortOrder] DEFAULT ((0)) NOT NULL,
    [DefinitionID]         INT            CONSTRAINT [DF_dnn_Lists_DefinitionID] DEFAULT ((0)) NOT NULL,
    [Description]          NVARCHAR (500) NULL,
    [PortalID]             INT            CONSTRAINT [DF_dnn_Lists_PortalID] DEFAULT ((-1)) NOT NULL,
    [SystemList]           BIT            CONSTRAINT [DF_dnn_Lists_SystemList] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_Lists] PRIMARY KEY CLUSTERED ([EntryID] ASC),
    CONSTRAINT [IX_dnn_Lists_ListName_Value_Text_ParentID] UNIQUE NONCLUSTERED ([ListName] ASC, [Value] ASC, [Text] ASC, [ParentID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Lists_ListName_ParentID]
    ON [dbo].[dnn_Lists]([ListName] ASC, [ParentID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Lists_ParentID]
    ON [dbo].[dnn_Lists]([ParentID] ASC, [ListName] ASC, [Value] ASC)
    INCLUDE([SortOrder], [DefinitionID], [Text]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Lists_SortOrder]
    ON [dbo].[dnn_Lists]([PortalID] ASC, [ParentID] ASC, [ListName] ASC, [SortOrder] ASC)
    INCLUDE([DefinitionID], [Value], [Text]);

