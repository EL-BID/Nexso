CREATE TABLE [dbo].[dnn_ContentItems] (
    [ContentItemID]        INT            IDENTITY (1, 1) NOT NULL,
    [Content]              NVARCHAR (MAX) NULL,
    [ContentTypeID]        INT            NOT NULL,
    [TabID]                INT            NOT NULL,
    [ModuleID]             INT            NOT NULL,
    [ContentKey]           NVARCHAR (250) NULL,
    [Indexed]              BIT            CONSTRAINT [DF_dnn_ContentItems_Indexed] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    [StateID]              INT            NULL,
    CONSTRAINT [PK_dnn_ContentItems] PRIMARY KEY CLUSTERED ([ContentItemID] ASC),
    CONSTRAINT [FK_dnn_ContentItems_dnn_ContentTypes] FOREIGN KEY ([ContentTypeID]) REFERENCES [dbo].[dnn_ContentTypes] ([ContentTypeID]),
    CONSTRAINT [FK_dnn_ContentItems_dnn_ContentWorkflowStates] FOREIGN KEY ([StateID]) REFERENCES [dbo].[dnn_ContentWorkflowStates] ([StateID]) ON DELETE SET NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ContentItems_TabID]
    ON [dbo].[dnn_ContentItems]([TabID] ASC);

