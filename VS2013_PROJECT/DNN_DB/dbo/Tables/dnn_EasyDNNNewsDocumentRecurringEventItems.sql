CREATE TABLE [dbo].[dnn_EasyDNNNewsDocumentRecurringEventItems] (
    [ArticleID]   INT NOT NULL,
    [RecurringID] INT NOT NULL,
    [DocumentID]  INT NOT NULL,
    [Position]    INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsDocumentRecurringEventItems] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [RecurringID] ASC, [DocumentID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsDocumentRecurringEventItems_EasyDNNNewsDocuments] FOREIGN KEY ([DocumentID]) REFERENCES [dbo].[dnn_EasyDNNNewsDocuments] ([DocEntryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsDocumentRecurringEventItems_EasyDNNNewsEventsRecurringData] FOREIGN KEY ([ArticleID], [RecurringID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsRecurringData] ([ArticleID], [RecurringID]) ON DELETE CASCADE
);

