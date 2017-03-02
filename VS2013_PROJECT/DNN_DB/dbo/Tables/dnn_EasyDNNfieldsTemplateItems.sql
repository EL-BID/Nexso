CREATE TABLE [dbo].[dnn_EasyDNNfieldsTemplateItems] (
    [FieldsTemplateID] INT NOT NULL,
    [CustomFieldID]    INT NOT NULL,
    [Position]         INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsTemplateItems] PRIMARY KEY CLUSTERED ([FieldsTemplateID] ASC, [CustomFieldID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsTemplateItems_EasyDNNfields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[dnn_EasyDNNfields] ([CustomFieldID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsTemplateItems_EasyDNNfieldsTemplate] FOREIGN KEY ([FieldsTemplateID]) REFERENCES [dbo].[dnn_EasyDNNfieldsTemplate] ([FieldsTemplateID]) ON DELETE CASCADE
);

