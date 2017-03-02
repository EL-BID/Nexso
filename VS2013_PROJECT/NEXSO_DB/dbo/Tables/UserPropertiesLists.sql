CREATE TABLE [dbo].[UserPropertiesLists] (
    [ListId]         UNIQUEIDENTIFIER NOT NULL,
    [UserPropertyId] INT              NOT NULL,
    [Category]       VARCHAR (50)     NOT NULL,
    [Key]            VARCHAR (50)     NOT NULL,
    CONSTRAINT [PK_UserPropertiesLists] PRIMARY KEY CLUSTERED ([ListId] ASC),
    CONSTRAINT [FK_UserPropertiesLists_UserProperties] FOREIGN KEY ([UserPropertyId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[UserPropertiesLists] NOCHECK CONSTRAINT [FK_UserPropertiesLists_UserProperties];



