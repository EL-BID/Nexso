CREATE TABLE [dbo].[dnn_ContentWorkflows] (
    [WorkflowID]         INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]           INT            NULL,
    [WorkflowName]       NVARCHAR (40)  NOT NULL,
    [Description]        NVARCHAR (256) NULL,
    [IsDeleted]          BIT            CONSTRAINT [DF_ContentWorkflows_IsDeleted] DEFAULT ((0)) NOT NULL,
    [StartAfterCreating] BIT            CONSTRAINT [DF_ContentWorkflows_StartAfterCreating] DEFAULT ((1)) NOT NULL,
    [StartAfterEditing]  BIT            CONSTRAINT [DF_ContentWorkflows_StartAfterEditing] DEFAULT ((1)) NOT NULL,
    [DispositionEnabled] BIT            CONSTRAINT [DF_ContentWorkflows_DispositionEnabled] DEFAULT ((0)) NOT NULL,
    [IsSystem]           BIT            DEFAULT ((0)) NOT NULL,
    [WorkflowKey]        NVARCHAR (40)  DEFAULT (N'') NOT NULL,
    CONSTRAINT [PK_dnn_ContentWorkflows] PRIMARY KEY CLUSTERED ([WorkflowID] ASC),
    CONSTRAINT [IX_dnn_ContentWorkflows] UNIQUE NONCLUSTERED ([PortalID] ASC, [WorkflowName] ASC)
);

