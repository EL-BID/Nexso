CREATE TABLE [dbo].[dnn_EasyDNNfieldsLocalization] (
    [CustomFieldID]      INT            NOT NULL,
    [LocaleCode]         NVARCHAR (20)  NOT NULL,
    [LabelValue]         NVARCHAR (500) NULL,
    [LabelHelp]          NVARCHAR (500) NULL,
    [ValidationErrorMsg] NVARCHAR (300) NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsLocalization] PRIMARY KEY CLUSTERED ([CustomFieldID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsLocalization_EasyDNNfields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[dnn_EasyDNNfields] ([CustomFieldID]) ON DELETE CASCADE
);

