CREATE TABLE [dbo].[dnn_UserRelationshipPreferences] (
    [PreferenceID]         INT      IDENTITY (1, 1) NOT NULL,
    [UserID]               INT      NOT NULL,
    [RelationshipID]       INT      NOT NULL,
    [DefaultResponse]      INT      NOT NULL,
    [CreatedByUserID]      INT      NOT NULL,
    [CreatedOnDate]        DATETIME CONSTRAINT [DF_dnn_UserRelationshipPreferences_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT      NOT NULL,
    [LastModifiedOnDate]   DATETIME CONSTRAINT [DF_dnn_UserRelationshipPreferences_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_UserRelationshipPreferences] PRIMARY KEY CLUSTERED ([PreferenceID] ASC, [RelationshipID] ASC),
    CONSTRAINT [FK_dnn_UserRelationshipPreferences_dnn_Relationships] FOREIGN KEY ([RelationshipID]) REFERENCES [dbo].[dnn_Relationships] ([RelationshipID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_UserRelationshipPreferences_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID])
);

