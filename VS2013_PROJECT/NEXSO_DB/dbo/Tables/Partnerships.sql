CREATE TABLE [Partnerships] (
    [OrganizationId]        UNIQUEIDENTIFIER NOT NULL,
    [OrganizationPartnerId] UNIQUEIDENTIFIER NOT NULL,
    [Type]                  VARCHAR (30)     NOT NULL,
    CONSTRAINT [PK__Partners__F81C45F89AED526D] PRIMARY KEY CLUSTERED ([OrganizationId] ASC, [OrganizationPartnerId] ASC),
    CONSTRAINT [FK__Partnersh__Organ__6EC0713C] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationID]),
    CONSTRAINT [FK__Partnersh__Organ__6FB49575] FOREIGN KEY ([OrganizationPartnerId]) REFERENCES [dbo].[Organization] ([OrganizationID])
);

