CREATE TABLE [dbo].[Messages] (
    [MessageId]   UNIQUEIDENTIFIER NOT NULL,
    [FromUserId]  INT              NULL,
    [ToUserId]    INT              NULL,
    [Message]     VARCHAR (MAX)    NULL,
    [DateCreated] DATETIME         NULL,
    [DateRead]    DATETIME         NULL,
    CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED ([MessageId] ASC)
);

