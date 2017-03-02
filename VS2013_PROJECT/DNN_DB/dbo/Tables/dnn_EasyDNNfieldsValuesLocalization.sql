CREATE TABLE [dbo].[dnn_EasyDNNfieldsValuesLocalization] (
    [CustomFieldID] INT            NOT NULL,
    [ArticleID]     INT            NOT NULL,
    [LocaleCode]    NVARCHAR (20)  NOT NULL,
    [RText]         NVARCHAR (MAX) NULL,
    [Text]          NVARCHAR (300) NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsValuesLocalization] PRIMARY KEY CLUSTERED ([CustomFieldID] ASC, [ArticleID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsValuesLocalization_EasyDNNfields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[dnn_EasyDNNfields] ([CustomFieldID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsValuesLocalization_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);

