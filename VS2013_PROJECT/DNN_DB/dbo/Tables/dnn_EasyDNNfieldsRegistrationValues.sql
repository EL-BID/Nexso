CREATE TABLE [dbo].[dnn_EasyDNNfieldsRegistrationValues] (
    [CustomFieldID]   INT             NOT NULL,
    [EventUserItemID] INT             NOT NULL,
    [RText]           NVARCHAR (MAX)  NULL,
    [Decimal]         DECIMAL (18, 4) NULL,
    [Int]             INT             NULL,
    [Text]            NVARCHAR (300)  NULL,
    [Bit]             BIT             NULL,
    [DateTime]        DATETIME        NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsRegistrationValues] PRIMARY KEY CLUSTERED ([CustomFieldID] ASC, [EventUserItemID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsRegistrationValues_EasyDNNfields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[dnn_EasyDNNfields] ([CustomFieldID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsRegistrationValues_EasyDNNNewsEventsUserItems] FOREIGN KEY ([EventUserItemID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsUserItems] ([Id]) ON DELETE CASCADE
);

