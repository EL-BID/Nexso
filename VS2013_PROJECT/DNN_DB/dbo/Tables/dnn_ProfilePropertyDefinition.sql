CREATE TABLE [dbo].[dnn_ProfilePropertyDefinition] (
    [PropertyDefinitionID] INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT             NULL,
    [ModuleDefID]          INT             NULL,
    [Deleted]              BIT             NOT NULL,
    [DataType]             INT             NOT NULL,
    [DefaultValue]         NTEXT           NULL,
    [PropertyCategory]     NVARCHAR (50)   NOT NULL,
    [PropertyName]         NVARCHAR (50)   NOT NULL,
    [Length]               INT             CONSTRAINT [DF_dnn_ProfilePropertyDefinition_Length] DEFAULT ((0)) NOT NULL,
    [Required]             BIT             NOT NULL,
    [ValidationExpression] NVARCHAR (2000) NULL,
    [ViewOrder]            INT             NOT NULL,
    [Visible]              BIT             NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    [DefaultVisibility]    INT             NULL,
    [ReadOnly]             BIT             CONSTRAINT [DF_dnn_ProfilePropertyDefinition_ReadOnly] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_ProfilePropertyDefinition] PRIMARY KEY CLUSTERED ([PropertyDefinitionID] ASC),
    CONSTRAINT [FK_dnn_ProfilePropertyDefinition_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ProfilePropertyDefinition]
    ON [dbo].[dnn_ProfilePropertyDefinition]([PortalID] ASC, [ModuleDefID] ASC, [PropertyName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ProfilePropertyDefinition_PropertyName]
    ON [dbo].[dnn_ProfilePropertyDefinition]([PropertyName] ASC);

