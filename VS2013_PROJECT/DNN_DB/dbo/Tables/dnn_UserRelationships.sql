CREATE TABLE [dbo].[dnn_UserRelationships] (
    [UserRelationshipID]   INT      IDENTITY (1, 1) NOT NULL,
    [UserID]               INT      NOT NULL,
    [RelatedUserID]        INT      NOT NULL,
    [RelationshipID]       INT      NOT NULL,
    [Status]               INT      NOT NULL,
    [CreatedByUserID]      INT      NOT NULL,
    [CreatedOnDate]        DATETIME CONSTRAINT [DF_dnn_UserRelationships_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT      NOT NULL,
    [LastModifiedOnDate]   DATETIME CONSTRAINT [DF_dnn_UserRelationships_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_UserRelationships] PRIMARY KEY CLUSTERED ([UserRelationshipID] ASC),
    CONSTRAINT [FK_dnn_UserRelationships_dnn_Relationships] FOREIGN KEY ([RelationshipID]) REFERENCES [dbo].[dnn_Relationships] ([RelationshipID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_UserRelationships_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]),
    CONSTRAINT [FK_dnn_UserRelationships_dnn_Users_OnRelatedUser] FOREIGN KEY ([RelatedUserID]) REFERENCES [dbo].[dnn_Users] ([UserID])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserRelationships_RelatedUserID]
    ON [dbo].[dnn_UserRelationships]([RelatedUserID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserRelationships_UserID]
    ON [dbo].[dnn_UserRelationships]([UserID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_UserRelationships_UserID_RelatedUserID_RelationshipID]
    ON [dbo].[dnn_UserRelationships]([UserID] ASC, [RelatedUserID] ASC, [RelationshipID] ASC);

