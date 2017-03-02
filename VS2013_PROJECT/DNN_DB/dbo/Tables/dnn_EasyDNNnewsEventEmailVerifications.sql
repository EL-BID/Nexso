CREATE TABLE [dbo].[dnn_EasyDNNnewsEventEmailVerifications] (
    [EventUserItemID] INT              NOT NULL,
    [ActivationCode]  UNIQUEIDENTIFIER NOT NULL,
    [IsActivated]     BIT              NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNnewsEventEmailVerifications] PRIMARY KEY CLUSTERED ([EventUserItemID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNnewsEventEmailVerifications_EasyDNNNewsEventsUserItems] FOREIGN KEY ([EventUserItemID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsUserItems] ([Id]) ON DELETE CASCADE
);

