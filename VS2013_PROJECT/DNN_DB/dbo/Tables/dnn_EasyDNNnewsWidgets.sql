CREATE TABLE [dbo].[dnn_EasyDNNnewsWidgets] (
    [ModuleID]      INT NOT NULL,
    [PortalID]      INT NOT NULL,
    [ViewControlID] INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNnewsWidgets] PRIMARY KEY CLUSTERED ([ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNnewsWidgets_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNnewsWidgets_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

