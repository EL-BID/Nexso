CREATE TABLE [dbo].[dnn_UsersOnline] (
    [UserID]         INT      NOT NULL,
    [PortalID]       INT      NOT NULL,
    [TabID]          INT      NOT NULL,
    [CreationDate]   DATETIME CONSTRAINT [DF__dnn_Users__Creat__3BFFE745] DEFAULT (getdate()) NOT NULL,
    [LastActiveDate] DATETIME CONSTRAINT [DF__dnn_Users__LastA__3CF40B7E] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_UsersOnline] PRIMARY KEY CLUSTERED ([UserID] ASC, [PortalID] ASC),
    CONSTRAINT [FK_dnn_UsersOnline_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_UsersOnline_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

