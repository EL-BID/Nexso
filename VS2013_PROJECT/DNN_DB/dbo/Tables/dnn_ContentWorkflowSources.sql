CREATE TABLE [dbo].[dnn_ContentWorkflowSources] (
    [SourceID]   INT            IDENTITY (1, 1) NOT NULL,
    [WorkflowID] INT            NOT NULL,
    [SourceName] NVARCHAR (20)  NOT NULL,
    [SourceType] NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_dnn_ContentWorkflowSources] PRIMARY KEY CLUSTERED ([SourceID] ASC),
    CONSTRAINT [FK_dnn_ContentWorkflowSources_dnn_ContentWorkflows] FOREIGN KEY ([WorkflowID]) REFERENCES [dbo].[dnn_ContentWorkflows] ([WorkflowID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_ContentWorkflowSources] UNIQUE NONCLUSTERED ([WorkflowID] ASC, [SourceName] ASC)
);

