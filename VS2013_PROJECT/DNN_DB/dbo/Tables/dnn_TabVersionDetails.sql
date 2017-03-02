CREATE TABLE [dbo].[dnn_TabVersionDetails] (
    [TabVersionDetailId]   INT           IDENTITY (1, 1) NOT NULL,
    [TabVersionId]         INT           NOT NULL,
    [ModuleId]             INT           NOT NULL,
    [ModuleVersion]        INT           NOT NULL,
    [PaneName]             NVARCHAR (50) NOT NULL,
    [ModuleOrder]          INT           NOT NULL,
    [Action]               INT           NOT NULL,
    [CreatedByUserID]      INT           NOT NULL,
    [CreatedOnDate]        DATETIME      NOT NULL,
    [LastModifiedByUserID] INT           NOT NULL,
    [LastModifiedOnDate]   DATETIME      NOT NULL,
    CONSTRAINT [PK_dnn_TabVersionDetails] PRIMARY KEY CLUSTERED ([TabVersionDetailId] ASC),
    CONSTRAINT [FK_dnn_TabVersionDetails_dnn_TabVersionId] FOREIGN KEY ([TabVersionId]) REFERENCES [dbo].[dnn_TabVersions] ([TabVersionId]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_TabVersionDetails_Unique(TabVersionId_ModuleId)] UNIQUE NONCLUSTERED ([TabVersionId] ASC, [ModuleId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_TabVersionDetails_TabVersionId]
    ON [dbo].[dnn_TabVersionDetails]([TabVersionId] ASC);

