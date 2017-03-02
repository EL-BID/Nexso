CREATE TABLE [dbo].[dnn_WorkflowStates] (
    [StateID]    INT           IDENTITY (1, 1) NOT NULL,
    [WorkflowID] INT           NOT NULL,
    [StateName]  NVARCHAR (50) NOT NULL,
    [Order]      INT           NOT NULL,
    [IsActive]   BIT           NOT NULL,
    [Notify]     BIT           NOT NULL,
    CONSTRAINT [PK_dnn_WorkflowStates] PRIMARY KEY CLUSTERED ([StateID] ASC),
    CONSTRAINT [FK_dnn_WorkflowStates_dnn_Workflow] FOREIGN KEY ([WorkflowID]) REFERENCES [dbo].[dnn_Workflow] ([WorkflowID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_WorkflowStates]
    ON [dbo].[dnn_WorkflowStates]([WorkflowID] ASC, [StateName] ASC);

