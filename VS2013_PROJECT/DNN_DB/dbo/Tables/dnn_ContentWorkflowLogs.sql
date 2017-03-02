CREATE TABLE [dbo].[dnn_ContentWorkflowLogs] (
    [WorkflowLogID] INT            IDENTITY (1, 1) NOT NULL,
    [Action]        NVARCHAR (40)  NOT NULL,
    [Comment]       NVARCHAR (MAX) NOT NULL,
    [Date]          DATETIME       NOT NULL,
    [User]          INT            NOT NULL,
    [WorkflowID]    INT            NOT NULL,
    [ContentItemID] INT            NOT NULL,
    [Type]          INT            DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [PK_dnn_ContentWorkflowLogs] PRIMARY KEY CLUSTERED ([WorkflowLogID] ASC),
    CONSTRAINT [FK_dnn_ContentWorkflowLogs_dnn_ContentItems] FOREIGN KEY ([ContentItemID]) REFERENCES [dbo].[dnn_ContentItems] ([ContentItemID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_ContentWorkflowLogs_dnn_ContentWorkflows] FOREIGN KEY ([WorkflowID]) REFERENCES [dbo].[dnn_ContentWorkflows] ([WorkflowID]) ON DELETE CASCADE
);

