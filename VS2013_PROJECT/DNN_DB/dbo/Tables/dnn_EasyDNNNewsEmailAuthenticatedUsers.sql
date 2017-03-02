CREATE TABLE [dbo].[dnn_EasyDNNNewsEmailAuthenticatedUsers] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]       INT            NOT NULL,
    [Email]          NVARCHAR (256) NOT NULL,
    [FirstName]      NVARCHAR (50)  NOT NULL,
    [LastName]       NVARCHAR (50)  NOT NULL,
    [CreatedOnDate]  DATETIME       CONSTRAINT [DF_dnn_EasyDNNNewsEmailAuthenticatedUsers_CreatedOnDate] DEFAULT (getutcdate()) NOT NULL,
    [IPAddress]      NVARCHAR (50)  NOT NULL,
    [EmailConfirmed] BIT            CONSTRAINT [DF_dnn_EasyDNNNewsEmailAuthenticatedUsers_Confirmed] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEmailAuthenticatedUsers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEmailAuthenticatedUsers_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsEmailAuthenticatedUsers] UNIQUE NONCLUSTERED ([PortalID] ASC, [Email] ASC)
);

