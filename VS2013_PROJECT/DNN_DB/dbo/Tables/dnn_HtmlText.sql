CREATE TABLE [dbo].[dnn_HtmlText] (
    [ModuleID]             INT      NOT NULL,
    [ItemID]               INT      IDENTITY (1, 1) NOT NULL,
    [Content]              NTEXT    NULL,
    [Version]              INT      NULL,
    [StateID]              INT      NULL,
    [IsPublished]          BIT      NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    [Summary]              NTEXT    NULL,
    CONSTRAINT [PK_dnn_HtmlText] PRIMARY KEY CLUSTERED ([ItemID] ASC),
    CONSTRAINT [FK_dnn_HtmlText_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_HtmlText_dnn_WorkflowStates] FOREIGN KEY ([StateID]) REFERENCES [dbo].[dnn_WorkflowStates] ([StateID])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_HtmlText_ModuleID_Version]
    ON [dbo].[dnn_HtmlText]([ModuleID] ASC, [Version] ASC);

