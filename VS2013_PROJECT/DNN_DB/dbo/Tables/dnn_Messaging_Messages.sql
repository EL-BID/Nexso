CREATE TABLE [dbo].[dnn_Messaging_Messages] (
    [MessageID]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [PortalID]               INT              NOT NULL,
    [FromUserID]             INT              NOT NULL,
    [ToUserName]             NVARCHAR (50)    NULL,
    [FromUserName]           NVARCHAR (50)    NULL,
    [ToUserID]               INT              NULL,
    [ToRoleID]               INT              NULL,
    [Status]                 TINYINT          NOT NULL,
    [Subject]                NVARCHAR (MAX)   NULL,
    [Body]                   NVARCHAR (MAX)   NULL,
    [Date]                   DATETIME         NOT NULL,
    [Conversation]           UNIQUEIDENTIFIER NOT NULL,
    [ReplyTo]                BIGINT           NULL,
    [AllowReply]             BIT              NOT NULL,
    [SkipPortal]             BIT              NOT NULL,
    [EmailSent]              BIT              NOT NULL,
    [EmailSentDate]          DATETIME         NULL,
    [EmailSchedulerInstance] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dnn_Messaging_Messages] PRIMARY KEY CLUSTERED ([MessageID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Messaging_Messages_EmailSent_EmailSchedulerInstance_Status]
    ON [dbo].[dnn_Messaging_Messages]([EmailSent] ASC, [EmailSchedulerInstance] ASC, [Status] ASC, [Date] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Messaging_Messages_FromUserID_Status]
    ON [dbo].[dnn_Messaging_Messages]([FromUserID] ASC, [Status] ASC, [Date] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Messaging_Messages_ToUserID_Status_SkipPortal]
    ON [dbo].[dnn_Messaging_Messages]([ToUserID] ASC, [Status] ASC, [SkipPortal] ASC, [Date] DESC);

