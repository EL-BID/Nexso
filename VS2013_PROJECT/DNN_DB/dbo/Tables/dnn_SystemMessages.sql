CREATE TABLE [dbo].[dnn_SystemMessages] (
    [MessageID]    INT           IDENTITY (1, 1) NOT NULL,
    [PortalID]     INT           NULL,
    [MessageName]  NVARCHAR (50) NOT NULL,
    [MessageValue] NTEXT         NOT NULL,
    CONSTRAINT [PK_dnn_SystemMessages] PRIMARY KEY CLUSTERED ([MessageID] ASC),
    CONSTRAINT [FK_dnn_SystemMessages_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_SystemMessages] UNIQUE NONCLUSTERED ([MessageName] ASC, [PortalID] ASC)
);

