CREATE TABLE [dbo].[dnn_EasyDNNNewsComments] (
    [CommentID]       INT            IDENTITY (1, 1) NOT NULL,
    [ArticleID]       INT            NOT NULL,
    [UserID]          INT            NOT NULL,
    [AnonymName]      NVARCHAR (128) NULL,
    [Comment]         NVARCHAR (MAX) NULL,
    [DateAdded]       DATETIME       NULL,
    [GoodVotes]       INT            NULL,
    [BadVotes]        INT            NULL,
    [Approved]        VARCHAR (5)    NULL,
    [CommentersEmail] NVARCHAR (250) NULL,
    [ReplayCommentID] INT            NULL,
    [ReplayLevel]     INT            NULL,
    [CommenterIP]     NVARCHAR (150) NULL,
    [PortalID]        INT            NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsComments] PRIMARY KEY CLUSTERED ([CommentID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsComments_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsComments_FK_ArticleID]
    ON [dbo].[dnn_EasyDNNNewsComments]([ArticleID] ASC);

