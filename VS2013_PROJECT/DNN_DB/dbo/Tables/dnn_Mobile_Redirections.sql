CREATE TABLE [dbo].[dnn_Mobile_Redirections] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [PortalId]             INT            NOT NULL,
    [Name]                 NVARCHAR (50)  NOT NULL,
    [Type]                 INT            NOT NULL,
    [SortOrder]            INT            CONSTRAINT [DF_dnn_Mobile_Redirections_SortOrder] DEFAULT ((0)) NOT NULL,
    [SourceTabId]          INT            NOT NULL,
    [IncludeChildTabs]     BIT            NOT NULL,
    [TargetType]           INT            NOT NULL,
    [TargetValue]          NVARCHAR (260) NOT NULL,
    [Enabled]              BIT            NOT NULL,
    [CreatedByUserID]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       CONSTRAINT [DF_dnn_Mobile_Redirections_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       CONSTRAINT [DF_dnn_Mobile_Redirections_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_Mobile_Redirections] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_Mobile_Redirections_dnn_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Mobile_Redirections_SortOrder]
    ON [dbo].[dnn_Mobile_Redirections]([SortOrder] ASC);

