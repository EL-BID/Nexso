CREATE TABLE [dbo].[dnn_EasyDNNfieldsLocalesCurrencyItems] (
    [ACodeBase]     NVARCHAR (5)   NOT NULL,
    [ACode]         NVARCHAR (5)   NOT NULL,
    [PortalID]      INT            NOT NULL,
    [LocaleKey]     NVARCHAR (10)  NOT NULL,
    [LocaleName]    NVARCHAR (250) NOT NULL,
    [DisplayFormat] NVARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsLocalesCurrencyItems] PRIMARY KEY CLUSTERED ([LocaleKey] ASC, [PortalID] ASC, [ACode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsLocalesCurrencyItems_EasyDNNfieldsExchangeRate] FOREIGN KEY ([ACodeBase], [PortalID], [ACode]) REFERENCES [dbo].[dnn_EasyDNNfieldsExchangeRate] ([ACodeBase], [PortalID], [ACode]) ON DELETE CASCADE ON UPDATE CASCADE
);

