CREATE TABLE [dbo].[dnn_EasyDNNfieldsCurrencySettings] (
    [ACodeBase]    NVARCHAR (5)   NOT NULL,
    [PortalID]     INT            NOT NULL,
    [ServiceUrl]   NVARCHAR (300) NULL,
    [UpdateRate]   DATETIME       NULL,
    [UpdateSource] BIT            CONSTRAINT [DF_dnn_EasyDNNfieldsCurrencySettings_UpdateSource] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsCurrencySettings] PRIMARY KEY CLUSTERED ([ACodeBase] ASC, [PortalID] ASC)
);

