CREATE TABLE [dbo].[dnn_Relationships] (
    [RelationshipID]       INT            IDENTITY (1, 1) NOT NULL,
    [RelationshipTypeID]   INT            NOT NULL,
    [Name]                 NVARCHAR (50)  NOT NULL,
    [Description]          NVARCHAR (500) NULL,
    [PortalID]             INT            NULL,
    [UserID]               INT            NULL,
    [DefaultResponse]      INT            NOT NULL,
    [CreatedByUserID]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       CONSTRAINT [DF_dnn_Relationships_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       CONSTRAINT [DF_dnn_Relationships_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_Relationships] PRIMARY KEY CLUSTERED ([RelationshipID] ASC),
    CONSTRAINT [FK_dnn_Relationships_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Relationships_dnn_RelationshipTypes] FOREIGN KEY ([RelationshipTypeID]) REFERENCES [dbo].[dnn_RelationshipTypes] ([RelationshipTypeID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Relationships_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Relationships_UserID]
    ON [dbo].[dnn_Relationships]([UserID] ASC);

