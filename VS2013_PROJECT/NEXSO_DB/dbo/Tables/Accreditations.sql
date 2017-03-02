CREATE TABLE [dbo].[Accreditations] (
    [AccreditationId] UNIQUEIDENTIFIER NOT NULL,
    [OrganizationId]  UNIQUEIDENTIFIER NOT NULL,
    [Type]            VARCHAR (30)     NOT NULL,
    [Name]            VARCHAR (30)     NOT NULL,
    [Description]     VARCHAR (500)    NOT NULL,
    [Content]         VARCHAR (MAX)    NULL,
    [DocumentId]      UNIQUEIDENTIFIER NULL,
    [Year]            VARCHAR (4)      NOT NULL,
    CONSTRAINT [PK_Accreditations] PRIMARY KEY CLUSTERED ([AccreditationId] ASC),
    CONSTRAINT [FK_Accreditations_Accreditations] FOREIGN KEY ([AccreditationId]) REFERENCES [dbo].[Accreditations] ([AccreditationId]),
    CONSTRAINT [FK_Accreditations_Documents] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[Documents] ([DocumentId]),
    CONSTRAINT [FK_Accreditations_Organization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationID])
);





