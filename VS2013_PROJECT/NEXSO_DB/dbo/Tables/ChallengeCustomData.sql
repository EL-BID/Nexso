CREATE TABLE [dbo].[ChallengeCustomData] (
    [ChallengeCustomDatalId] UNIQUEIDENTIFIER NOT NULL,
    [ChallengeReference]     VARCHAR (50)     NOT NULL,
    [Language]               VARCHAR (50)     NOT NULL,
    [EligibilityTemplate]    VARCHAR (MAX)    NULL,
    [CustomDataTemplate]     VARCHAR (MAX)    NULL,
    [Tags]                   VARCHAR (MAX)    NULL,
    [PreConditionsTemplate]  VARCHAR (MAX)    NULL,
    [PostConditionsTemplate] VARCHAR (MAX)    NULL,
    [Scoring]                VARCHAR (MAX)    NULL,
    [Title]                  VARCHAR (1000)   NULL,
    [Description]            VARCHAR (MAX)    NULL,
    [TagLine]                VARCHAR (1000)   NULL,
    [BannerFront]            VARCHAR (500)    NULL,
    [UrlChallengeFront]      VARCHAR (500)    NULL,
    CONSTRAINT [PK_ChallengeCustomData] PRIMARY KEY CLUSTERED ([ChallengeCustomDatalId] ASC),
    CONSTRAINT [FK_ChallengeCustomData_Challenges] FOREIGN KEY ([ChallengeReference]) REFERENCES [dbo].[ChallengeSchemas] ([ChallengeReference])
);


GO
ALTER TABLE [dbo].[ChallengeCustomData] NOCHECK CONSTRAINT [FK_ChallengeCustomData_Challenges];



