CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalFilterByTagID] (
    [FilterPortalID] INT NOT NULL,
    [TagID]          INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalFilterByTagID] PRIMARY KEY CLUSTERED ([FilterPortalID] ASC, [TagID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalFilterByTagID_EasyDNNNewsNewTags] FOREIGN KEY ([TagID]) REFERENCES [dbo].[dnn_EasyDNNNewsNewTags] ([TagID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalFilterByTagID_Portals] FOREIGN KEY ([FilterPortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

