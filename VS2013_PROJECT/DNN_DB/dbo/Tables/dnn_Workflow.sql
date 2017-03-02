CREATE TABLE [dbo].[dnn_Workflow] (
    [WorkflowID]   INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]     INT             NULL,
    [WorkflowName] NVARCHAR (50)   NOT NULL,
    [Description]  NVARCHAR (2000) NULL,
    [IsDeleted]    BIT             NOT NULL,
    CONSTRAINT [PK_dnn_Workflow] PRIMARY KEY CLUSTERED ([WorkflowID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Workflow]
    ON [dbo].[dnn_Workflow]([PortalID] ASC, [WorkflowName] ASC);

