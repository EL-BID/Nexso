CREATE TABLE [dbo].[dnn_EasyDNNNewsAutorGroupItems] (
    [AuthorProfileID] INT      NOT NULL,
    [GroupID]         INT      NOT NULL,
    [DateAdded]       DATETIME NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsAutorGroupItems_1] PRIMARY KEY CLUSTERED ([AuthorProfileID] ASC, [GroupID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsAutorGroupItems_EasyDNNNewsAuthorGroups1] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[dnn_EasyDNNNewsAuthorGroups] ([GroupID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsAutorGroupItems_EasyDNNNewsAuthorProfile] FOREIGN KEY ([AuthorProfileID]) REFERENCES [dbo].[dnn_EasyDNNNewsAuthorProfile] ([AuthorProfileID]) ON DELETE CASCADE
);

