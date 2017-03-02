CREATE PROCEDURE [dbo].[dnn_UpdateServer]
    @ServerID           INT,
    @URL                NVARCHAR(255),
    @UniqueId           NVARCHAR(200),
    @Enabled            BIT,
    @Group              NVARCHAR(200)
AS
    UPDATE dbo.dnn_WebServers
        SET 
            URL = @URL,
            UniqueId = @UniqueId,
            Enabled = @Enabled,
            ServerGroup = @Group
        WHERE  ServerID = @ServerID

