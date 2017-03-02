CREATE TABLE [dbo].[dnn_EasyDNNNewsEventPostSettings] (
    [Id]                      INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]                INT            NOT NULL,
    [PostType]                TINYINT        NOT NULL,
    [Name]                    NVARCHAR (250) NOT NULL,
    [SentToSubscriptionUsers] BIT            NOT NULL,
    [SendToEventAtendees]     BIT            NOT NULL,
    [EmailSubject]            NVARCHAR (256) NOT NULL,
    [Template]                NVARCHAR (MAX) NOT NULL,
    [SendType]                TINYINT        NOT NULL,
    [SendIntervalValue]       INT            NULL,
    [Active]                  BIT            NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventPostSettings] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventPostSettings_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

