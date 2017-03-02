CREATE TABLE [dbo].[SolutionLocations] (
    [SolutionLocationId] UNIQUEIDENTIFIER NOT NULL,
    [SolutionId]         UNIQUEIDENTIFIER NOT NULL,
    [Country]            VARCHAR (50)     NULL,
    [Region]             VARCHAR (50)     NULL,
    [City]               VARCHAR (50)     NULL,
    [Latitude]           DECIMAL (10, 7)  NULL,
    [Longitude]          DECIMAL (10, 7)  NULL,
    [GoogleLocation]     VARCHAR (1000)   NULL,
    [Address]            VARCHAR (100)    NULL,
    [PostalCode]         VARCHAR (50)     NULL,
    CONSTRAINT [PK_SolutionLocations] PRIMARY KEY CLUSTERED ([SolutionLocationId] ASC),
    CONSTRAINT [FK_SolutionLocations_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId])
);


GO
ALTER TABLE [dbo].[SolutionLocations] NOCHECK CONSTRAINT [FK_SolutionLocations_Solution];



