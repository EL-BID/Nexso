CREATE TABLE [dbo].[dnn_HtmlTextLog] (
    [HtmlTextLogID]   INT             IDENTITY (1, 1) NOT NULL,
    [ItemID]          INT             NOT NULL,
    [StateID]         INT             NOT NULL,
    [Comment]         NVARCHAR (4000) NULL,
    [Approved]        BIT             NOT NULL,
    [CreatedByUserID] INT             NOT NULL,
    [CreatedOnDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dnn_HtmlTextLog] PRIMARY KEY CLUSTERED ([HtmlTextLogID] ASC),
    CONSTRAINT [FK_dnn_HtmlTextLog_dnn_HtmlText] FOREIGN KEY ([ItemID]) REFERENCES [dbo].[dnn_HtmlText] ([ItemID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_HtmlTextLog_dnn_WorkflowStates] FOREIGN KEY ([StateID]) REFERENCES [dbo].[dnn_WorkflowStates] ([StateID])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_HtmlTextLog_ItemID]
    ON [dbo].[dnn_HtmlTextLog]([ItemID] ASC)
    INCLUDE([HtmlTextLogID]);

