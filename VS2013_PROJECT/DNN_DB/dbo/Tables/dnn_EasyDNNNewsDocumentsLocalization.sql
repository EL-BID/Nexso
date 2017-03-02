CREATE TABLE [dbo].[dnn_EasyDNNNewsDocumentsLocalization] (
    [DocumentID] INT           NOT NULL,
    [LocaleCode] NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsDocumentsLocalization] PRIMARY KEY CLUSTERED ([DocumentID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsDocumentsLocalization_EasyDNNNewsDocuments] FOREIGN KEY ([DocumentID]) REFERENCES [dbo].[dnn_EasyDNNNewsDocuments] ([DocEntryID]) ON DELETE CASCADE
);

