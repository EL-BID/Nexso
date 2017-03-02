CREATE TABLE [dbo].[dnn_CoreMessaging_MessageAttachments] (
    [MessageAttachmentID]  INT      IDENTITY (1, 1) NOT NULL,
    [MessageID]            INT      NOT NULL,
    [FileID]               INT      NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_MessageAttachments] PRIMARY KEY CLUSTERED ([MessageAttachmentID] ASC),
    CONSTRAINT [FK_dnn_CoreMessaging_MessageAttachments_dnn_CoreMessaging_Messages] FOREIGN KEY ([MessageID]) REFERENCES [dbo].[dnn_CoreMessaging_Messages] ([MessageID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_CoreMessaging_MessageAttachments_MessageID]
    ON [dbo].[dnn_CoreMessaging_MessageAttachments]([MessageID] ASC);

