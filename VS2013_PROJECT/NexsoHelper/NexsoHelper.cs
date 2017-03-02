using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DotNetNuke.Common;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Localization;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;


/// <summary>
/// Summary description for NexsoHelper
/// </summary>
public class NexsoHelper
{
	public NexsoHelper()
	{
		//
		// TODO: Add constructor logic here
		//
	}

    public static string GetCulturedUrlByTabName(string keyName)
    {
      
        var objTabController = new DotNetNuke.Entities.Tabs.TabController();
        var tab = objTabController.GetTabByName(keyName, PortalController.GetCurrentPortalSettings().PortalId);
        if (tab != null)
        {
            var culturedTab =
                objTabController.GetTabByCulture(tab.TabID, PortalController.GetCurrentPortalSettings().PortalId,
                                                 LocaleController.Instance.GetCurrentLocale(PortalController.GetCurrentPortalSettings().PortalId));
            if (culturedTab != null)
                return Globals.NavigateURL(culturedTab.TabID);
        }
        return string.Empty; 
    }

    public static string GetCulturedUrlByTabName(string keyName,int portalId,string language)
    {
        try
        {
            var objTabController = new DotNetNuke.Entities.Tabs.TabController();
            var tab = objTabController.GetTabByName(keyName, portalId);
            if (tab != null)
            {
                Locale locale = LocaleController.Instance.GetLocale(language);


                var culturedTab =
                    objTabController.GetTabByCulture(tab.TabID, portalId, locale);
                if (culturedTab != null)
                    return Globals.NavigateURL(culturedTab.TabID);
            }
            return string.Empty;
        }
        catch(Exception ee)
        {
            DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);
            return string.Empty;
        }
    }

    /// <summary>
    /// Autor: Jesús Alberto Correa L.
    /// Description: This variable gets the directory where the application is running and create or update files Lucene
    /// Folder (Bin af principal solution)
    /// </summary>
    public static string AssemblyDirectory
    {
        get
        {
            string codeBase = System.Reflection.Assembly.GetExecutingAssembly().CodeBase;
            UriBuilder uri = new UriBuilder(codeBase);
            return System.IO.Path.GetDirectoryName(Uri.UnescapeDataString(uri.Path));
        }
    }

    /// <summary>
    /// This class replace all accent for idioma
    /// </summary>
    /// <param name="inputString"></param>
    /// <returns></returns>
    public static string DecodeHtmlAndRemoveAccents(string inputString)
    {
        inputString = HttpUtility.HtmlDecode(inputString);

        Regex a = new Regex("[á|à|ä|â|ã]", RegexOptions.Compiled);
        Regex e = new Regex("[é|è|ë|ê]", RegexOptions.Compiled);
        Regex i = new Regex("[í|ì|ï|î]", RegexOptions.Compiled);
        Regex o = new Regex("[ó|ò|ö|ô|õ]", RegexOptions.Compiled);
        Regex u = new Regex("[ú|ù|ü|û]", RegexOptions.Compiled);
        Regex c = new Regex("[ç]", RegexOptions.Compiled);

        inputString = a.Replace(inputString, "a");
        inputString = e.Replace(inputString, "e");
        inputString = i.Replace(inputString, "i");
        inputString = o.Replace(inputString, "o");
        inputString = u.Replace(inputString, "u");
        inputString = c.Replace(inputString, "c");

        return inputString;
    }
}