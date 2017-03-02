CREATE TABLE [dbo].[dnn_EasyDNNfieldsValues] (
    [CustomFieldID] INT             NOT NULL,
    [ArticleID]     INT             NOT NULL,
    [RText]         NVARCHAR (MAX)  NULL,
    [Decimal]       DECIMAL (18, 4) NULL,
    [Int]           INT             NULL,
    [Text]          NVARCHAR (300)  NULL,
    [Bit]           BIT             NULL,
    [DateTime]      DATETIME        NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsValues] PRIMARY KEY CLUSTERED ([CustomFieldID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsValues_EasyDNNfields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[dnn_EasyDNNfields] ([CustomFieldID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsValues_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);

