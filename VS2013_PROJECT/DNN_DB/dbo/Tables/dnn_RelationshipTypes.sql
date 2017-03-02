CREATE TABLE [dbo].[dnn_RelationshipTypes] (
    [RelationshipTypeID]   INT            IDENTITY (1, 1) NOT NULL,
    [Direction]            INT            NOT NULL,
    [Name]                 NVARCHAR (50)  NOT NULL,
    [Description]          NVARCHAR (500) NULL,
    [CreatedByUserID]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       CONSTRAINT [DF_dnn_RelationshipTypes_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       CONSTRAINT [DF_dnn_RelationshipTypes_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_RelationshipTypes] PRIMARY KEY CLUSTERED ([RelationshipTypeID] ASC)
);

