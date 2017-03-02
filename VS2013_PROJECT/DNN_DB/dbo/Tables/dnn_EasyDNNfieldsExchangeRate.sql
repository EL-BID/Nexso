CREATE TABLE [dbo].[dnn_EasyDNNfieldsExchangeRate] (
    [ACodeBase]       NVARCHAR (5)    NOT NULL,
    [PortalID]        INT             NOT NULL,
    [ACode]           NVARCHAR (5)    NOT NULL,
    [Unit]            INT             NOT NULL,
    [ExchangeRate]    DECIMAL (19, 6) NOT NULL,
    [DateTime]        DATETIME        NOT NULL,
    [Position]        INT             NOT NULL,
    [DisplayOnReport] BIT             NOT NULL,
    [DisplayFormat]   NVARCHAR (10)   NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsCurrencyRate] PRIMARY KEY CLUSTERED ([ACodeBase] ASC, [PortalID] ASC, [ACode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsExchangeRate_EasyDNNfieldsCurrency] FOREIGN KEY ([ACode]) REFERENCES [dbo].[dnn_EasyDNNfieldsCurrency] ([ACode]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsExchangeRate_EasyDNNfieldsCurrencySettings] FOREIGN KEY ([ACodeBase], [PortalID]) REFERENCES [dbo].[dnn_EasyDNNfieldsCurrencySettings] ([ACodeBase], [PortalID]) ON DELETE CASCADE ON UPDATE CASCADE
);

