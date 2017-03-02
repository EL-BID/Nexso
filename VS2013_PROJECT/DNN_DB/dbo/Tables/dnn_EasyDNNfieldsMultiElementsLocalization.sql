CREATE TABLE [dbo].[dnn_EasyDNNfieldsMultiElementsLocalization] (
    [FieldElementID] INT            NOT NULL,
    [LocaleCode]     NVARCHAR (20)  NOT NULL,
    [Text]           NVARCHAR (300) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsMultiElementsLocalization] PRIMARY KEY CLUSTERED ([FieldElementID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsMultiElementsLocalization_EasyDNNfieldsMultiElements] FOREIGN KEY ([FieldElementID]) REFERENCES [dbo].[dnn_EasyDNNfieldsMultiElements] ([FieldElementID]) ON DELETE CASCADE
);

