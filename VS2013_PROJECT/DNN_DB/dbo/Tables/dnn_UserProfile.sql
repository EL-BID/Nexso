CREATE TABLE [dbo].[dnn_UserProfile] (
    [ProfileID]            INT             IDENTITY (1, 1) NOT NULL,
    [UserID]               INT             NOT NULL,
    [PropertyDefinitionID] INT             NOT NULL,
    [PropertyValue]        NVARCHAR (3750) NULL,
    [PropertyText]         NVARCHAR (MAX)  NULL,
    [Visibility]           INT             CONSTRAINT [DF__dnn_UserP__Visib__1352D76D] DEFAULT ((0)) NOT NULL,
    [LastUpdatedDate]      DATETIME        NOT NULL,
    [ExtendedVisibility]   VARCHAR (400)   NULL,
    CONSTRAINT [PK_dnn_UserProfile] PRIMARY KEY CLUSTERED ([ProfileID] ASC),
    CONSTRAINT [FK_dnn_UserProfile_dnn_ProfilePropertyDefinition] FOREIGN KEY ([PropertyDefinitionID]) REFERENCES [dbo].[dnn_ProfilePropertyDefinition] ([PropertyDefinitionID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_UserProfile_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserProfile]
    ON [dbo].[dnn_UserProfile]([UserID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserProfile_LastUpdatedDate]
    ON [dbo].[dnn_UserProfile]([LastUpdatedDate] DESC)
    INCLUDE([UserID]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserProfile_PropertyDefinitionID]
    ON [dbo].[dnn_UserProfile]([PropertyDefinitionID] ASC)
    INCLUDE([ProfileID], [UserID], [PropertyValue]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserProfile_UserID_PropertyDefinitionID]
    ON [dbo].[dnn_UserProfile]([UserID] ASC, [PropertyDefinitionID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UserProfile_Visibility]
    ON [dbo].[dnn_UserProfile]([UserID] ASC, [ProfileID] ASC)
    INCLUDE([PropertyDefinitionID], [PropertyValue], [PropertyText], [Visibility], [LastUpdatedDate], [ExtendedVisibility]);

