CREATE TABLE [dbo].[dnn_ExtensionUrlProviderTab] (
    [ExtensionUrlProviderID] INT NOT NULL,
    [PortalID]               INT NOT NULL,
    [TabID]                  INT NOT NULL,
    [IsActive]               BIT NOT NULL,
    CONSTRAINT [PK_dnn_ExtensionUrlProviderTab] PRIMARY KEY CLUSTERED ([ExtensionUrlProviderID] ASC, [PortalID] ASC, [TabID] ASC)
);

