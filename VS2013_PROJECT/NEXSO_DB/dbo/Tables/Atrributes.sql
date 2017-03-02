CREATE TABLE [dbo].[Atrributes] (
    [AttributeID]    UNIQUEIDENTIFIER NOT NULL,
    [OrganizationID] UNIQUEIDENTIFIER NOT NULL,
    [Type]           VARCHAR (50)     NOT NULL,
    [Value]          VARCHAR (50)     NOT NULL,
    [ValueType]      VARCHAR (50)     NULL,
    [Description]    VARCHAR (800)    NULL,
    [Label]          VARCHAR (800)    NULL,
    CONSTRAINT [PK_Atrributes] PRIMARY KEY CLUSTERED ([AttributeID] ASC),
    CONSTRAINT [FK_Atrributes_Organization] FOREIGN KEY ([OrganizationID]) REFERENCES [dbo].[Organization] ([OrganizationID])
);

