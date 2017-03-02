CREATE TABLE [dbo].[dnn_TabUrls] (
    [TabId]                INT            NOT NULL,
    [SeqNum]               INT            NOT NULL,
    [Url]                  NVARCHAR (200) NOT NULL,
    [QueryString]          NVARCHAR (200) NULL,
    [HttpStatus]           NVARCHAR (50)  NOT NULL,
    [CultureCode]          NVARCHAR (50)  NULL,
    [IsSystem]             BIT            CONSTRAINT [DF_dnn_TabUrls_IsSystem] DEFAULT ((0)) NOT NULL,
    [PortalAliasId]        INT            NULL,
    [PortalAliasUsage]     INT            NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_TabRedirect] PRIMARY KEY CLUSTERED ([TabId] ASC, [SeqNum] ASC),
    CONSTRAINT [FK_dnn_TabUrls_Tabs] FOREIGN KEY ([TabId]) REFERENCES [dbo].[dnn_Tabs] ([TabID]) ON DELETE CASCADE
);

