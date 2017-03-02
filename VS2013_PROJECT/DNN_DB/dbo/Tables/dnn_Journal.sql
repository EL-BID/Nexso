CREATE TABLE [dbo].[dnn_Journal] (
    [JournalId]        INT              IDENTITY (1, 1) NOT NULL,
    [JournalTypeId]    INT              NOT NULL,
    [UserId]           INT              NULL,
    [DateCreated]      DATETIME         NULL,
    [DateUpdated]      DATETIME         NULL,
    [PortalId]         INT              NULL,
    [ProfileId]        INT              CONSTRAINT [DF_dnn_Journal_ProfileId] DEFAULT ((-1)) NOT NULL,
    [GroupId]          INT              CONSTRAINT [DF_dnn_Journal_GroupId] DEFAULT ((-1)) NOT NULL,
    [Title]            NVARCHAR (255)   NULL,
    [Summary]          NVARCHAR (2000)  NULL,
    [ItemData]         NVARCHAR (2000)  NULL,
    [ImageURL]         NVARCHAR (255)   NULL,
    [ObjectKey]        NVARCHAR (255)   NULL,
    [AccessKey]        UNIQUEIDENTIFIER NULL,
    [ContentItemId]    INT              NULL,
    [IsDeleted]        BIT              CONSTRAINT [DF_dnn_Journal_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CommentsDisabled] BIT              CONSTRAINT [DF_dnn_Journal_CommentsDisabled] DEFAULT ((0)) NOT NULL,
    [CommentsHidden]   BIT              CONSTRAINT [DF_dnn_Journal_CommentsHidden] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_Journal] PRIMARY KEY CLUSTERED ([JournalId] ASC),
    CONSTRAINT [FK_dnn_Journal_JournalTypes] FOREIGN KEY ([JournalTypeId]) REFERENCES [dbo].[dnn_Journal_Types] ([JournalTypeId])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Journal_ContentItemId]
    ON [dbo].[dnn_Journal]([ContentItemId] ASC)
    INCLUDE([GroupId]);

