CREATE TABLE [dbo].[dnn_AnonymousUsers] (
    [UserID]         CHAR (36) NOT NULL,
    [PortalID]       INT       NOT NULL,
    [TabID]          INT       NOT NULL,
    [CreationDate]   DATETIME  CONSTRAINT [DF_dnn_AnonymousUsers_CreationDate] DEFAULT (getdate()) NOT NULL,
    [LastActiveDate] DATETIME  CONSTRAINT [DF_dnn_AnonymousUsers_LastActiveDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_AnonymousUsers] PRIMARY KEY CLUSTERED ([UserID] ASC, [PortalID] ASC),
    CONSTRAINT [FK_dnn_AnonymousUsers_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

