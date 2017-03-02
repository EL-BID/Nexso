CREATE TABLE [dbo].[dnn_EasyDNNNewsEventUsers] (
    [Id]                       INT IDENTITY (1, 1) NOT NULL,
    [DNNUserID]                INT NULL,
    [EmailAuthenticatedUserID] INT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventUsers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_dnn_EasyDNNNewsEventUsers_ValueCheck] CHECK ((1)=case when [EmailAuthenticatedUserID] IS NULL AND [DNNUserID] IS NOT NULL OR [EmailAuthenticatedUserID] IS NOT NULL AND [DNNUserID] IS NULL then (1) else (0) end),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventUsers_EasyDNNNewsEmailAuthenticatedUsers] FOREIGN KEY ([EmailAuthenticatedUserID]) REFERENCES [dbo].[dnn_EasyDNNNewsEmailAuthenticatedUsers] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventUsers_EasyDNNNewsEventUsers] FOREIGN KEY ([DNNUserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);

