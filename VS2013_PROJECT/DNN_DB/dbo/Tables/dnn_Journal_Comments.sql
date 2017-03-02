CREATE TABLE [dbo].[dnn_Journal_Comments] (
    [CommentId]   INT             IDENTITY (1, 1) NOT NULL,
    [JournalId]   INT             NOT NULL,
    [UserId]      INT             NOT NULL,
    [Comment]     NVARCHAR (2000) NULL,
    [DateCreated] DATETIME        NOT NULL,
    [DateUpdated] DATETIME        NOT NULL,
    [CommentXML]  XML             NULL,
    CONSTRAINT [PK_dnn_Journal_Comments] PRIMARY KEY CLUSTERED ([CommentId] ASC),
    CONSTRAINT [FK_dnn_JournalComments_Journal] FOREIGN KEY ([JournalId]) REFERENCES [dbo].[dnn_Journal] ([JournalId]) ON DELETE CASCADE
);

