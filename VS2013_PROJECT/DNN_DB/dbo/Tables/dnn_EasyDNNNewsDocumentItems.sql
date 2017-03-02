CREATE TABLE [dbo].[dnn_EasyDNNNewsDocumentItems] (
    [ArticleID]  INT NOT NULL,
    [DocumentID] INT NOT NULL,
    [Position]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsDocumentItems] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [DocumentID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsDocumentItems_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsDocumentItems_EasyDNNNewsDocuments] FOREIGN KEY ([DocumentID]) REFERENCES [dbo].[dnn_EasyDNNNewsDocuments] ([DocEntryID]) ON DELETE CASCADE
);

