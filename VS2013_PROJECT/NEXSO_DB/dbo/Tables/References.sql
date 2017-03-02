CREATE TABLE [dbo].[References] (
    [ReferenceId]    UNIQUEIDENTIFIER NOT NULL,
    [OrganizationId] UNIQUEIDENTIFIER NOT NULL,
    [UserId]         INT              NOT NULL,
    [Type]           VARCHAR (30)     NOT NULL,
    [Comment]        VARCHAR (MAX)    NOT NULL,
    [Created]        DATETIME         NOT NULL,
    [Updated]        DATETIME         NOT NULL,
    [Deleted]        BIT              NOT NULL,
    CONSTRAINT [PK_References] PRIMARY KEY CLUSTERED ([ReferenceId] ASC),
    CONSTRAINT [FK_References_Organization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationID]),
    CONSTRAINT [FK_References_References] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);





