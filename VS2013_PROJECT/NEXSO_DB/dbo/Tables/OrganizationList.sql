CREATE TABLE [OrganizationList] (
    [ListId]         UNIQUEIDENTIFIER NOT NULL,
    [OrganizationId] UNIQUEIDENTIFIER NOT NULL,
    [Category]       VARCHAR (50)     NOT NULL,
    [Key]            VARCHAR (50)     NOT NULL,
    CONSTRAINT [PK_OrganizationList] PRIMARY KEY CLUSTERED ([ListId] ASC),
    CONSTRAINT [FK_OrganizationList_Organization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationID])
);

