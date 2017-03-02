CREATE TABLE [dbo].[dnn_WebServers] (
    [ServerID]         INT            IDENTITY (1, 1) NOT NULL,
    [ServerName]       NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [LastActivityDate] DATETIME       NOT NULL,
    [URL]              NVARCHAR (255) NULL,
    [IISAppName]       NVARCHAR (200) CONSTRAINT [DF_dnn_WebServers_IISAppName] DEFAULT ('') NOT NULL,
    [Enabled]          BIT            CONSTRAINT [DF_dnn_WebServers_Enabled] DEFAULT ((1)) NOT NULL,
    [ServerGroup]      NVARCHAR (200) NULL,
    [UniqueId]         NVARCHAR (200) NULL,
    [PingFailureCount] INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_WebServers] PRIMARY KEY CLUSTERED ([ServerID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_WebServers_ServerName]
    ON [dbo].[dnn_WebServers]([ServerName] ASC, [IISAppName] ASC);

