CREATE FUNCTION [dbo].[dnn_Journal_User_Permissions]
(
    @PortalId int,
    @UserId int,
    @RegisteredRoleId int
)
RETURNS 
@tmp TABLE (seckey nvarchar(200))

AS
BEGIN
IF @UserId > 0
        BEGIN
            IF @RegisteredRoleId = 1
                SELECT @RegisteredRoleId = RegisteredRoleId FROM dbo.[dnn_Portals] WHERE PortalID = @PortalId
            INSERT INTO @tmp (seckey) VALUES ('U' + Cast(@UserId as nvarchar(200)))
            INSERT INTO @tmp (seckey) VALUES ('P' + Cast(@UserId as nvarchar(200)))
            INSERT INTO @tmp (seckey) VALUES ('F' + Cast(@UserId as nvarchar(200)))
            IF EXISTS(SELECT RoleId FROM dbo.[dnn_UserRoles] WHERE UserID = @UserId AND RoleId = @RegisteredRoleId
                        AND    (EffectiveDate <= getdate() or EffectiveDate is null)
                        AND    (ExpiryDate >= getdate() or ExpiryDate is null))
                    INSERT INTO @tmp (seckey) VALUES ('C')
            
        END
        
    INSERT INTO @tmp (seckey) VALUES ('E')
    
    INSERT INTO @tmp (seckey)
    SELECT 'R' + CAST(ur.RoleId as nvarchar(200)) 
        FROM dbo.[dnn_UserRoles] as ur
            INNER JOIN dbo.[dnn_Users] as u on ur.UserId = u.UserId
            INNER JOIN dbo.[dnn_Roles] as r on ur.RoleId = r.RoleId
        WHERE  u.UserId = @UserId
            AND    r.PortalId = @PortalId
            AND    (EffectiveDate <= getdate() or EffectiveDate is null)
            AND    (ExpiryDate >= getdate() or ExpiryDate is null)
    INSERT INTO @tmp (seckey)
        SELECT (SELECT CASE WHEN @UserID = ur.UserId 
                        THEN 'F' + CAST(RelatedUserID as nvarchar(200))
                        ELSE 'F' + CAST(ur.UserId as nvarchar(200)) END) 
        FROM dbo.[dnn_UserRelationships] ur
        INNER JOIN dbo.[dnn_Relationships] r ON ur.RelationshipID = r.RelationshipID AND r.RelationshipTypeID = 1
        WHERE (ur.UserId = @UserId OR RelatedUserID = @UserId) AND Status = 2
    RETURN 
END

