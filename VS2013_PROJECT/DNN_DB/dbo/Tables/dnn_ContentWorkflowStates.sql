CREATE TABLE [dbo].[dnn_ContentWorkflowStates] (
    [StateID]                          INT             IDENTITY (1, 1) NOT NULL,
    [WorkflowID]                       INT             NOT NULL,
    [StateName]                        NVARCHAR (40)   NOT NULL,
    [Order]                            INT             NOT NULL,
    [IsActive]                         BIT             CONSTRAINT [DF_ContentWorkflowStates_IsActive] DEFAULT ((1)) NOT NULL,
    [SendEmail]                        BIT             CONSTRAINT [DF_ContentWorkflowStates_SendEmail] DEFAULT ((0)) NOT NULL,
    [SendMessage]                      BIT             CONSTRAINT [DF_ContentWorkflowStates_SendMessage] DEFAULT ((0)) NOT NULL,
    [IsDisposalState]                  BIT             CONSTRAINT [DF_ContentWorkflowStates_IsDisposalState] DEFAULT ((0)) NOT NULL,
    [OnCompleteMessageSubject]         NVARCHAR (256)  CONSTRAINT [DF_ContentWorkflowStates_OnCompleteMessageSubject] DEFAULT (N'') NOT NULL,
    [OnCompleteMessageBody]            NVARCHAR (1024) CONSTRAINT [DF_ContentWorkflowStates_OnCompleteMessageBody] DEFAULT (N'') NOT NULL,
    [OnDiscardMessageSubject]          NVARCHAR (256)  CONSTRAINT [DF_ContentWorkflowStates_OnDiscardMessageSubject] DEFAULT (N'') NOT NULL,
    [OnDiscardMessageBody]             NVARCHAR (1024) CONSTRAINT [DF_ContentWorkflowStates_OnDiscardMessageBody] DEFAULT (N'') NOT NULL,
    [IsSystem]                         BIT             DEFAULT ((0)) NOT NULL,
    [SendNotification]                 BIT             DEFAULT ((1)) NOT NULL,
    [SendNotificationToAdministrators] BIT             DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_ContentWorkflowStates] PRIMARY KEY CLUSTERED ([StateID] ASC),
    CONSTRAINT [FK_dnn_ContentWorkflowStates_dnn_ContentWorkflows] FOREIGN KEY ([WorkflowID]) REFERENCES [dbo].[dnn_ContentWorkflows] ([WorkflowID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_ContentWorkflowStates] UNIQUE NONCLUSTERED ([WorkflowID] ASC, [StateName] ASC)
);

