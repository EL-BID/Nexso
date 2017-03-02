CREATE TABLE [dbo].[dnn_EasyDNNfieldsMultiSelected] (
    [FieldElementID] INT NOT NULL,
    [CustomFieldID]  INT NOT NULL,
    [ArticleID]      INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsMultiSelected] PRIMARY KEY CLUSTERED ([FieldElementID] ASC, [CustomFieldID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsMultiSelected_EasyDNNfieldsMultiElements1] FOREIGN KEY ([FieldElementID]) REFERENCES [dbo].[dnn_EasyDNNfieldsMultiElements] ([FieldElementID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsMultiSelected_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);

