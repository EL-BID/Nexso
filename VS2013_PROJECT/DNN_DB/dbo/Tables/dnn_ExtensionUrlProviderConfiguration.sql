CREATE TABLE [dbo].[dnn_ExtensionUrlProviderConfiguration] (
    [ExtensionUrlProviderID] INT NOT NULL,
    [PortalID]               INT NOT NULL,
    CONSTRAINT [PK_dnn_ExtensionUrlProviderConfiguration] PRIMARY KEY CLUSTERED ([ExtensionUrlProviderID] ASC, [PortalID] ASC)
);

