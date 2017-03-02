CREATE PROCEDURE [dbo].[dnn_DeletePortalDesktopModules]
    @PortalID        int,
    @DesktopModuleId int
AS
BEGIN
    IF @PortalID is not null AND @DesktopModuleId is not null
        DELETE FROM dbo.dnn_PortalDesktopModules WHERE PortalId = @PortalID AND DesktopModuleId = @DesktopModuleId
    ELSE 
        BEGIN
            IF @PortalID is not null
                DELETE FROM dbo.dnn_PortalDesktopModules WHERE PortalId = @PortalID
            ELSE
                BEGIN 
                    IF @DesktopModuleId is not null
                        DELETE FROM dbo.dnn_PortalDesktopModules WHERE DesktopModuleId = @DesktopModuleId
                END
        END
END

