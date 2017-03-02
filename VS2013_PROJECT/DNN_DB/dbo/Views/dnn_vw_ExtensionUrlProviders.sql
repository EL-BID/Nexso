CREATE VIEW [dbo].[dnn_vw_ExtensionUrlProviders]
AS
	SELECT     
		P.ExtensionUrlProviderID, 
		PC.PortalID, 
		P.ProviderName, 
		P.IsActive, 
		P.RewriteAllUrls, 
		P.RedirectAllUrls, 
		P.ReplaceAllUrls, 
		P.DesktopModuleId
	FROM    dbo.dnn_ExtensionUrlProviderConfiguration PC
		RIGHT OUTER JOIN dbo.dnn_ExtensionUrlProviders P ON PC.ExtensionUrlProviderID = P.ExtensionUrlProviderID

