CREATE TABLE [dbo].[dnn_ContentWorkflowActions] (
    [ActionId]      INT            IDENTITY (1, 1) NOT NULL,
    [ContentTypeId] INT            NOT NULL,
    [ActionType]    NVARCHAR (50)  NOT NULL,
    [ActionSource]  NVARCHAR (256) NOT NULL,
    CONSTRAINT [PK_dnn_ContentWorkflowActions] PRIMARY KEY CLUSTERED ([ActionId] ASC),
    CONSTRAINT [FK_dnn_ContentWorkflowActions_dnn_ContentTypes] FOREIGN KEY ([ContentTypeId]) REFERENCES [dbo].[dnn_ContentTypes] ([ContentTypeID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ContentTypeId_ActionType]
    ON [dbo].[dnn_ContentWorkflowActions]([ContentTypeId] ASC, [ActionType] ASC);

