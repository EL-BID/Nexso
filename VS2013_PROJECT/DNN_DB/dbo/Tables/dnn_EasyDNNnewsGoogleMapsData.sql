CREATE TABLE [dbo].[dnn_EasyDNNnewsGoogleMapsData] (
    [GoogleMapID] INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]    INT            NOT NULL,
    [UserID]      INT            NOT NULL,
    [Global]      BIT            NOT NULL,
    [DateAdded]   DATETIME       NOT NULL,
    [Latitude]    NVARCHAR (50)  NOT NULL,
    [Longitude]   NVARCHAR (50)  NOT NULL,
    [MapType]     NVARCHAR (20)  NOT NULL,
    [MapZoom]     INT            NOT NULL,
    [Scrollwheel] NVARCHAR (10)  NOT NULL,
    [MapWidth]    INT            NOT NULL,
    [MapHeight]   INT            NOT NULL,
    [PointData]   NVARCHAR (MAX) NOT NULL,
    [FullToken]   NVARCHAR (MAX) NOT NULL,
    [Position]    INT            NULL,
    CONSTRAINT [PK_dnn_EasyDNNnewsGoogleMapsData] PRIMARY KEY CLUSTERED ([GoogleMapID] ASC)
);

