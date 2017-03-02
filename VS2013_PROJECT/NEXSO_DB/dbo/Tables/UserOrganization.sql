CREATE TABLE [dbo].[UserOrganization] (
    [OrganizationID] UNIQUEIDENTIFIER NOT NULL,
    [UserID]         INT              NOT NULL,
    [Role]           INT              NOT NULL,
    CONSTRAINT [PK_UserOrganization] PRIMARY KEY CLUSTERED ([OrganizationID] ASC, [UserID] ASC),
    CONSTRAINT [FK_UserOrganization_Organization] FOREIGN KEY ([OrganizationID]) REFERENCES [dbo].[Organization] ([OrganizationID])
);


GO
ALTER TABLE [dbo].[UserOrganization] NOCHECK CONSTRAINT [FK_UserOrganization_Organization];



