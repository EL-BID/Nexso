CREATE procedure [dbo].[dnn_GetDatabaseInstallVersion]
AS
SELECT  TOP 1 Major ,
        Minor ,
        Build
FROM    dbo.dnn_Version V
WHERE   VersionId IN ( SELECT   MAX(VersionId) AS VersionID
                       FROM     dbo.[dnn_Version]
                       GROUP BY CONVERT(NVARCHAR(8), CreatedDate, 112) )

