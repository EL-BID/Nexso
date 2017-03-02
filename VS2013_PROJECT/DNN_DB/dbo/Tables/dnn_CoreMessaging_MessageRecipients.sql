CREATE TABLE [dbo].[dnn_CoreMessaging_MessageRecipients] (
    [RecipientID]            INT              IDENTITY (1, 1) NOT NULL,
    [MessageID]              INT              NOT NULL,
    [UserID]                 INT              NOT NULL,
    [Read]                   BIT              CONSTRAINT [DF__dnn_CoreMe__Read__3AC1AA49] DEFAULT ((0)) NOT NULL,
    [Archived]               BIT              CONSTRAINT [DF__dnn_CoreM__Archi__3BB5CE82] DEFAULT ((0)) NOT NULL,
    [EmailSent]              BIT              CONSTRAINT [DF__dnn_CoreM__Email__3CA9F2BB] DEFAULT ((0)) NOT NULL,
    [EmailSentDate]          DATETIME         NULL,
    [EmailSchedulerInstance] UNIQUEIDENTIFIER NULL,
    [CreatedByUserID]        INT              NULL,
    [CreatedOnDate]          DATETIME         NULL,
    [LastModifiedByUserID]   INT              NULL,
    [LastModifiedOnDate]     DATETIME         NULL,
    [SendToast]              BIT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_MessageRecipients] PRIMARY KEY CLUSTERED ([RecipientID] ASC),
    CONSTRAINT [FK_dnn_CoreMessaging_MessageRecipients_dnn_CoreMessaging_Messages] FOREIGN KEY ([MessageID]) REFERENCES [dbo].[dnn_CoreMessaging_Messages] ([MessageID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_CoreMessaging_MessageRecipients_UserID]
    ON [dbo].[dnn_CoreMessaging_MessageRecipients]([UserID] ASC, [Read] DESC, [Archived] ASC);

