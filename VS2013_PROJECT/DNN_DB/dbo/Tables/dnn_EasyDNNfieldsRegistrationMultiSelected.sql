CREATE TABLE [dbo].[dnn_EasyDNNfieldsRegistrationMultiSelected] (
    [FieldElementID]  INT NOT NULL,
    [CustomFieldID]   INT NOT NULL,
    [EventUserItemID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsRegistrationMultiSelected] PRIMARY KEY CLUSTERED ([FieldElementID] ASC, [CustomFieldID] ASC, [EventUserItemID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsRegistrationMultiSelected_EasyDNNfieldsMultiElements] FOREIGN KEY ([FieldElementID]) REFERENCES [dbo].[dnn_EasyDNNfieldsMultiElements] ([FieldElementID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsRegistrationMultiSelected_EasyDNNNewsEventsUserItems] FOREIGN KEY ([EventUserItemID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsUserItems] ([Id]) ON DELETE CASCADE
);

