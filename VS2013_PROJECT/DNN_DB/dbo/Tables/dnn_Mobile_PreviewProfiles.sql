CREATE TABLE [dbo].[dnn_Mobile_PreviewProfiles] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [PortalId]             INT            NOT NULL,
    [Name]                 NVARCHAR (50)  NOT NULL,
    [Width]                INT            NOT NULL,
    [Height]               INT            NOT NULL,
    [UserAgent]            NVARCHAR (260) NOT NULL,
    [SortOrder]            INT            CONSTRAINT [DF_dnn_Mobile_PreviewProfiles_SortOrder] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       CONSTRAINT [DF_dnn_Mobile_PreviewProfiles_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       CONSTRAINT [DF_dnn_Mobile_PreviewProfiles_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_Mobile_PreviewProfiles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_Mobile_PreviewProfiles_dnn_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Mobile_PreviewProfiles_SortOrder]
    ON [dbo].[dnn_Mobile_PreviewProfiles]([SortOrder] ASC);

