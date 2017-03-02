CREATE TABLE [dbo].[dnn_EasyDNNNewsLinkItems] (
    [ArticleID] INT NOT NULL,
    [LinkID]    INT NOT NULL,
    [Position]  INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsLinkItems] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [LinkID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsLinkItems_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsLinkItems_EasyDNNNewsLinks] FOREIGN KEY ([LinkID]) REFERENCES [dbo].[dnn_EasyDNNNewsLinks] ([LinkID]) ON DELETE CASCADE
);

