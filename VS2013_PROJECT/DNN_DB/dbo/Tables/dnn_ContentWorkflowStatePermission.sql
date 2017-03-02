CREATE TABLE [dbo].[dnn_ContentWorkflowStatePermission] (
    [WorkflowStatePermissionID] INT      IDENTITY (1, 1) NOT NULL,
    [StateID]                   INT      NOT NULL,
    [PermissionID]              INT      NOT NULL,
    [AllowAccess]               BIT      NOT NULL,
    [RoleID]                    INT      NULL,
    [UserID]                    INT      NULL,
    [CreatedByUserID]           INT      NULL,
    [CreatedOnDate]             DATETIME NULL,
    [LastModifiedByUserID]      INT      NULL,
    [LastModifiedOnDate]        DATETIME NULL,
    CONSTRAINT [PK_dnn_ContentWorkflowStatePermission] PRIMARY KEY CLUSTERED ([WorkflowStatePermissionID] ASC),
    CONSTRAINT [FK_dnn_ContentWorkflowStatePermission_dnn_ContentWorkflowStates] FOREIGN KEY ([StateID]) REFERENCES [dbo].[dnn_ContentWorkflowStates] ([StateID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_ContentWorkflowStatePermission_dnn_Permission] FOREIGN KEY ([PermissionID]) REFERENCES [dbo].[dnn_Permission] ([PermissionID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_ContentWorkflowStatePermission_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_ContentWorkflowStatePermission] UNIQUE NONCLUSTERED ([StateID] ASC, [PermissionID] ASC, [RoleID] ASC, [UserID] ASC)
);

