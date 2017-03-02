using System;
using System.Collections.Generic;
using System.Linq;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using NexsoProBLL;
using NexsoProDAL;
using System.Threading;
using Newtonsoft.Json;
using System.Xml;
using System.IO;

/// <summary>
/// This control get information of challenge (NZChallengeEngineWizard)
/// https://www.nexso.org/en-us/c/EconomiaNaranja
/// </summary>
public partial class NZChallengePage : PortalModuleBase, IActionable
{
    #region Public Member Variables
    string jsonData;

    #endregion

    #region Private Member Variables
    private string challengeReference;
    private string pageReference;
    private string solutionType;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Load variables fro module settings
    /// </summary>
    private void LoadVariables()
    {
        if (Settings["ChallengeReference"]!=null)
            challengeReference = Settings["ChallengeReference"].ToString();
        if (Settings["Page"] != null)
            pageReference = Settings["Page"].ToString();
        if (Settings["SolutionType"] != null)
            solutionType = Settings["SolutionType"].ToString();
        else
            solutionType = string.Empty;
    }

    /// <summary>
    /// Load ChallengePageComponent from database
    /// </summary>
    private void LoadContext()
    {
        var challengeCustomDataComponent = new ChallengeCustomDataComponent(challengeReference, Thread.CurrentThread.CurrentCulture.Name);
        var page = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, pageReference);
        jsonData = createContext(challengeCustomDataComponent.ChallengeCustomData, page.ChallengePage);
    }

    /// <summary>
    /// Load template to use
    /// </summary>
    private void RenderContent()
    {
        if (Settings.Contains("Template"))
        {
            litContent.Text = Settings["Template"].ToString();
        }
    }

    private void RenderJsonData()
    {
        hfJsonContext.Value = jsonData;
    }

    /// <summary>
    /// Load the timeline (Home page of the challenge)
    /// </summary>
    /// <param name="challengeCustomData"></param>
    /// <param name="dictionary"></param>
    /// <returns></returns>
    private List<TimeLine> GenerateTimeLine(ChallengeCustomData challengeCustomData, List<GenericObject> dictionary)
    {
        List<TimeLine> listReturn = new List<TimeLine>();
        string format = "MMMM d  \\'yy";
        if (Thread.CurrentThread.CurrentCulture.Name == "es-ES")
            format = "d MMMM  \\'yy";

        if (challengeCustomData.ChallengeSchema.PreLaunch.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            var list = dictionary.SingleOrDefault(a => a.value1 == "Pre-Launch");
            string title = Localization.GetString("Pre-Launch", LocalResourceFile);
            if (list != null)
            {
                title = list.value2;
            }
            listReturn.Add(new TimeLine()
            {
                DateValue = challengeCustomData.ChallengeSchema.PreLaunch.GetValueOrDefault(),
                Title = title,
                ToolTip = title,
                State = "nextStep",
                FormatedDateTime = challengeCustomData.ChallengeSchema.PreLaunch.GetValueOrDefault().ToString(format)
            }
            );
        }

        if (challengeCustomData.ChallengeSchema.Launch.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            var list = dictionary.SingleOrDefault(a => a.value1 == "Launch");
            string title = Localization.GetString("Launch", LocalResourceFile);
            if (list != null)
            {
                title = list.value2;
            }

            listReturn.Add(new TimeLine()
            {
                DateValue = challengeCustomData.ChallengeSchema.Launch.GetValueOrDefault(),
                Title = title,
                ToolTip = title,
                State = "nextStep",
                FormatedDateTime = challengeCustomData.ChallengeSchema.Launch.GetValueOrDefault().ToString(format)
            }

            );
        }
        if (challengeCustomData.ChallengeSchema.EntryFrom.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            if (challengeCustomData.ChallengeSchema.EntryFrom.GetValueOrDefault() !=
                challengeCustomData.ChallengeSchema.Launch.GetValueOrDefault())
            {
                var list = dictionary.SingleOrDefault(a => a.value1 == "AvailableEntryFrom");
                string title = Localization.GetString("AvailableEntryFrom", LocalResourceFile);
                if (list != null)
                {
                    title = list.value2;
                }

                listReturn.Add(new TimeLine()
                {
                    DateValue = challengeCustomData.ChallengeSchema.EntryFrom.GetValueOrDefault(),
                    Title = title,
                    ToolTip = title,
                    State = "nextStep",
                    FormatedDateTime = challengeCustomData.ChallengeSchema.EntryFrom.GetValueOrDefault().ToString(format)
                }

                );
            }
        }

        if (challengeCustomData.ChallengeSchema.EntryTo.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            var list = dictionary.SingleOrDefault(a => a.value1 == "AvailableEntryTo");
            string title = Localization.GetString("AvailableEntryTo", LocalResourceFile);
            if (list != null)
            {
                title = list.value2;
            }

            listReturn.Add(new TimeLine()
            {
                DateValue = challengeCustomData.ChallengeSchema.EntryTo.GetValueOrDefault(),
                Title = title,
                ToolTip = title,
                State = "nextStep",
                FormatedDateTime = challengeCustomData.ChallengeSchema.EntryTo.GetValueOrDefault().ToString(format)
            }

            );
        }

        if (challengeCustomData.ChallengeSchema.ScoringL1From.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            var list = dictionary.SingleOrDefault(a => a.value1 == "EvaluationFrom");
            string title = Localization.GetString("EvaluationFrom", LocalResourceFile);
            if (list != null)
            {
                title = list.value2;
            }
            listReturn.Add(new TimeLine()
            {
                DateValue = challengeCustomData.ChallengeSchema.ScoringL1From.GetValueOrDefault(),
                Title = title,
                ToolTip = title,
                State = "nextStep",
                FormatedDateTime = challengeCustomData.ChallengeSchema.ScoringL1From.GetValueOrDefault().ToString(format)
            }

            );
        }
        if (challengeCustomData.ChallengeSchema.ScoringL1To.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            var list = dictionary.SingleOrDefault(a => a.value1 == "EvaluationTo");
            string title = Localization.GetString("EvaluationTo", LocalResourceFile);
            if (list != null)
            {
                title = list.value2;
            }
            listReturn.Add(new TimeLine()
            {
                DateValue = challengeCustomData.ChallengeSchema.ScoringL1To.GetValueOrDefault(),
                Title = title,
                ToolTip = title,
                State = "nextStep",
                FormatedDateTime = challengeCustomData.ChallengeSchema.ScoringL1To.GetValueOrDefault().ToString(format)
            }

            );
        }
        if (challengeCustomData.ChallengeSchema.Closed.GetValueOrDefault(DateTime.MinValue) != DateTime.MinValue)
        {
            var list = dictionary.SingleOrDefault(a => a.value1 == "Closed");
            string title = Localization.GetString("Closed", LocalResourceFile);
            if (list != null)
            {
                title = list.value2;
            }
            listReturn.Add(new TimeLine()
            {
                DateValue = challengeCustomData.ChallengeSchema.Closed.GetValueOrDefault(),
                Title = title,
                ToolTip = title,
                State = "nextStep",
                FormatedDateTime = challengeCustomData.ChallengeSchema.Closed.GetValueOrDefault().ToString(format)
            }

            );
        }
        TimeLine lastObject = null;
        foreach (var item in listReturn)
        {


            if (item.DateValue <= DateTime.Now)
            {
                item.State = "prevStep";
            }
            else
            {
                if (lastObject != null)
                {
                    lastObject.State = "currentStep";
                }

                break;
            }
            lastObject = item;
        }

        return listReturn;
    }
    #endregion
   
    #region Public Properties
    

    #endregion

    #region Public Methods
    public List<GenericObject> GetGenericFAQ(string xmlData)
    {

        List<GenericObject> list = new List<GenericObject>();

        if (!string.IsNullOrEmpty(xmlData))
        {
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;


            byteArray = encoding.GetBytes(xmlData);

            // Load the memory stream
            MemoryStream memoryStream = new MemoryStream(byteArray);
            //XmlDocument doc = new XmlDocument();
            memoryStream.Seek(0, SeekOrigin.Begin);

            string QUESTION, ANSWER, ID, POSITION;


            if (byteArray.Length > 0)
            {
                try
                {

                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {

                        QUESTION = ANSWER = ID = POSITION = string.Empty;

                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "FIELD")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ID")
                                {
                                    ID = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "QUESTION")
                                {
                                    QUESTION = reader.ReadString();
                                    break;
                                }
                            }

                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ANSWER")
                                {
                                    ANSWER = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "POSITION")
                                {
                                    POSITION = reader.ReadString();
                                    break;
                                }
                            }

                            if (!string.IsNullOrEmpty(QUESTION) && !string.IsNullOrEmpty(ANSWER))
                            {

                                list.Add(new GenericObject { id = new Guid(ID), value1 = QUESTION, value2 = ANSWER, position = Convert.ToInt32(POSITION) });

                            }

                        }
                    }
                }
                catch
                {

                }
            }
        }

        return list;
    }
    public List<GenericObject> GetGenericObjectList(string xmlData)
    {

        List<GenericObject> list = new List<GenericObject>();









        if (!string.IsNullOrEmpty(xmlData))
        {
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;


            byteArray = encoding.GetBytes(xmlData);

            // Load the memory stream
            MemoryStream memoryStream = new MemoryStream(byteArray);
            //XmlDocument doc = new XmlDocument();
            memoryStream.Seek(0, SeekOrigin.Begin);

            string DESCRIPTION, NAME, ID, PHOTO, POSITION, TAGLINE, TAG;


            if (byteArray.Length > 0)
            {
                try
                {

                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {

                        DESCRIPTION = NAME = ID = PHOTO = POSITION = TAGLINE = TAG = string.Empty;

                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "FIELD")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ID")
                                {
                                    ID = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "PHOTO")
                                {
                                    PHOTO = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "NAME")
                                {
                                    NAME = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TAGLINE")
                                {
                                    TAGLINE = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "DESCRIPTION")
                                {
                                    DESCRIPTION = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "POSITION")
                                {
                                    POSITION = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TAG")
                                {
                                    TAG = reader.ReadString();
                                    break;
                                }
                                if (reader.NodeType == XmlNodeType.EndElement &&
                                    reader.Name == "FIELD")
                                {
                                    break;
                                }
                            }

                            if (!string.IsNullOrEmpty(DESCRIPTION) && !string.IsNullOrEmpty(NAME))
                            {

                                list.Add(new GenericObject { id = new Guid(ID), value1 = NAME, value2 = DESCRIPTION, value3 = PHOTO, value4 = TAGLINE, value5 = TAG, position = Convert.ToInt32(POSITION) });

                            }

                        }
                    }
                }
                catch
                {

                }
            }


            return list.OrderBy(x => x.position).ToList();
        }
        return null;
    }
    public List<GenericObject> GetGenericElegibility(string xmlData)
    {

        List<GenericObject> list = new List<GenericObject>();

        if (!string.IsNullOrEmpty(xmlData))
        {
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;


            byteArray = encoding.GetBytes(xmlData);

            // Load the memory stream
            MemoryStream memoryStream = new MemoryStream(byteArray);
            //XmlDocument doc = new XmlDocument();
            memoryStream.Seek(0, SeekOrigin.Begin);

            string TEXT, TYPE, ID, POSITION;


            if (byteArray.Length > 0)
            {
                try
                {

                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {

                        TEXT = TYPE = ID = POSITION = string.Empty;

                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "FIELD")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ID")
                                {
                                    ID = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TYPE")
                                {
                                    TYPE = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TEXT")
                                {
                                    TEXT = reader.ReadString();
                                    break;
                                }
                            }


                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "POSITION")
                                {
                                    POSITION = reader.ReadString();
                                    break;
                                }
                            }

                            if (!string.IsNullOrEmpty(TYPE) && !string.IsNullOrEmpty(TEXT))
                            {

                                list.Add(new GenericObject { id = new Guid(ID), value1 = TYPE, value2 = TEXT, position = Convert.ToInt32(POSITION) });

                            }

                        }
                    }
                }
                catch
                {

                }
            }
        }

        return list.OrderBy(x => x.position).ToList();
    }
    public List<GenericObject> GetGenericListDictionary(string xmlData)
    {

        List<GenericObject> list = new List<GenericObject>();

        if (!string.IsNullOrEmpty(xmlData))
        {
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;


            byteArray = encoding.GetBytes(xmlData);

            // Load the memory stream
            MemoryStream memoryStream = new MemoryStream(byteArray);
            //XmlDocument doc = new XmlDocument();
            memoryStream.Seek(0, SeekOrigin.Begin);

            string KEY, VALUE, ID;


            if (byteArray.Length > 0)
            {
                try
                {

                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {

                        KEY = VALUE = ID = string.Empty;

                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "FIELD")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ID")
                                {
                                    ID = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "KEY")
                                {
                                    KEY = reader.ReadString();
                                    break;
                                }
                            }

                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "VALUE")
                                {
                                    VALUE = reader.ReadString();
                                    break;
                                }
                            }


                            if (!string.IsNullOrEmpty(VALUE) && !string.IsNullOrEmpty(KEY))
                            {

                                list.Add(new GenericObject { id = new Guid(ID), value1 = KEY, value2 = VALUE });

                            }

                        }
                    }
                }
                catch
                {

                }
            }
        }

        return list;
    }
    #endregion

    #region Protected Methods

    protected string createContext(ChallengeCustomData challengeCustomData, ChallengePage challengePage)
    {
        //main contenxt
        NZChallengePage.ContextPage objReturn = new NZChallengePage.ContextPage();
        objReturn.ChallengeCustomDatalId = challengeCustomData.ChallengeCustomDatalId.ToString();
        objReturn.ChallengeReference = challengeCustomData.ChallengeReference;
        objReturn.SolutionType = solutionType;
        objReturn.Description = challengeCustomData.Description;
        objReturn.Language = challengeCustomData.Language;
        objReturn.TagLine = challengeCustomData.TagLine;
        objReturn.Tags = challengeCustomData.Tags;
        objReturn.Title = challengeCustomData.Title;
        ChallengeComponent challengeComponent = new ChallengeComponent(challengeCustomData.ChallengeReference);
        var file = challengeComponent.Challenge.ChallengeFiles.FirstOrDefault(x => x.Language == challengeCustomData.Language && x.ObjectType == "Banner Challenge" && (x.Delete == null || x.Delete == false));
        if (file != null)
            objReturn.BannerImage = file.ObjectLocation;


        objReturn.ChallengeSchemaContext = new ChallengeSchemaContext();
        objReturn.ChallengeSchemaContext.Closed = challengeCustomData.ChallengeSchema.Closed.GetValueOrDefault(DateTime.MinValue).ToString(); ;
        objReturn.ChallengeSchemaContext.EnterUrl = challengeCustomData.ChallengeSchema.EnterUrl;
        objReturn.ChallengeSchemaContext.EntryFrom = challengeCustomData.ChallengeSchema.EntryFrom.GetValueOrDefault(DateTime.MinValue).ToString();
        objReturn.ChallengeSchemaContext.EntryTo = challengeCustomData.ChallengeSchema.EntryTo.GetValueOrDefault(DateTime.MinValue).ToString();
        objReturn.ChallengeSchemaContext.Flavor = challengeCustomData.ChallengeSchema.Flavor;
        objReturn.ChallengeSchemaContext.Launch = challengeCustomData.ChallengeSchema.Launch.GetValueOrDefault(DateTime.MinValue).ToString();
        objReturn.ChallengeSchemaContext.OutUrl = challengeCustomData.ChallengeSchema.OutUrl;
        objReturn.ChallengeSchemaContext.PreLaunch = challengeCustomData.ChallengeSchema.PreLaunch.GetValueOrDefault(DateTime.MinValue).ToString();
        objReturn.ChallengeSchemaContext.PublishType = challengeCustomData.ChallengeSchema.PublishType;
        objReturn.ChallengeSchemaContext.ScoringL1From = challengeCustomData.ChallengeSchema.ScoringL1From.GetValueOrDefault(DateTime.MinValue).ToString();
        objReturn.ChallengeSchemaContext.ScoringL2From = challengeCustomData.ChallengeSchema.ScoringL2From.GetValueOrDefault(DateTime.MinValue).ToString();
        objReturn.ChallengeSchemaContext.Url = challengeCustomData.ChallengeSchema.Url;

        var judgesPage = challengeCustomData.ChallengePages.SingleOrDefault(a => a.Reference == "judges");
        if (judgesPage != null)
            objReturn.Judges = GetGenericObjectList(judgesPage.Content);
        objReturn.Dictionary = GetGenericListDictionary(challengeCustomData.Tags);
        objReturn.TimesLine = GenerateTimeLine(challengeCustomData, objReturn.Dictionary);
        objReturn.CurrentPageContext = new CurrentPageContext();
        objReturn.CurrentPageContext.ChallengePageId = challengePage.ChallengePageId.ToString();
        objReturn.CurrentPageContext.Content = challengePage.Content;
        objReturn.CurrentPageContext.ContentType = challengePage.ContentType;
        objReturn.CurrentPageContext.Description = challengePage.Description;
        objReturn.CurrentPageContext.Order = challengePage.Order.GetValueOrDefault(0).ToString();
        objReturn.CurrentPageContext.Reference = challengePage.Reference;
        objReturn.CurrentPageContext.Tagline = challengePage.Tagline;
        objReturn.CurrentPageContext.Title = challengePage.Title;
        objReturn.CurrentPageContext.Url = challengePage.Url;
        objReturn.CurrentPageContext.Visibility = challengePage.Visibility;
        objReturn.Eligibility = GetGenericElegibility(challengeCustomData.EligibilityTemplate);


        switch (challengePage.Reference)
        {
            case "judges":
                {
                    objReturn.CurrentPageContext.GenericObject = objReturn.Judges;
                    break;
                }
            case "faq":
                {
                    objReturn.CurrentPageContext.GenericObject = GetGenericFAQ(challengePage.Content);
                    break;
                }
            case "partners":
                {
                    objReturn.CurrentPageContext.GenericObject = GetGenericObjectList(challengePage.Content);
                    break;
                }


        }


        objReturn.PagesContext = new List<PagesContext>();


        foreach (var item in challengeCustomData.ChallengePages.OrderBy(a => a.Order))
        {
            if (item.Title != string.Empty)
            {
                objReturn.PagesContext.Add(new PagesContext
                {
                    Tagline = item.Tagline,
                    Title = item.Title,
                    Url = item.Url,
                    Visibility = item.Visibility
                });
            }
        }



        return JsonConvert.SerializeObject(objReturn);
    }

    #endregion

    #region Subclasses

    public class ContextPage
    {
        public string ChallengeCustomDatalId { get; set; }
        public string ChallengeReference { get; set; }
        public string Language { get; set; }
        public string Tags { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string TagLine { get; set; }
        public ChallengeSchemaContext ChallengeSchemaContext { get; set; }
        public CurrentPageContext CurrentPageContext { get; set; }
        public List<PagesContext> PagesContext { get; set; }
        public List<TimeLine> TimesLine { get; set; }
        public List<GenericObject> Judges { get; set; }
        public List<GenericObject> Eligibility { get; set; }
        public List<GenericObject> Dictionary { get; set; }
        public string BannerImage { get; set; }
        public string SolutionType { get; set; }


    }
    public class GenericObject
    {
        public Guid id { get; set; }
        public string value1 { get; set; }
        public string value2 { get; set; }
        public string value3 { get; set; }
        public string value4 { get; set; }
        public string value5 { get; set; }
        public int position { get; set; }
    }
    public class ChallengeSchemaContext
    {
        public string Url { get; set; }
        public string EnterUrl { get; set; }
        public string OutUrl { get; set; }
        public string Flavor { get; set; }
        public string PreLaunch { get; set; }
        public string Launch { get; set; }
        public string EntryFrom { get; set; }
        public string EntryTo { get; set; }
        public string ScoringL1From { get; set; }
        public string ScoringL2From { get; set; }
        public string Closed { get; set; }
        public string PublishType { get; set; }

    }
    public class CurrentPageContext
    {
        public string ChallengePageId { get; set; }
        public string Title { get; set; }
        public string Tagline { get; set; }
        public string Description { get; set; }
        public string Content { get; set; }
        public string Reference { get; set; }
        public string Url { get; set; }
        public string Order { get; set; }
        public string Visibility { get; set; }
        public string ContentType { get; set; }
        public List<GenericObject> GenericObject { get; set; }
    }
    public class PagesContext
    {
        public string Title { get; set; }
        public string Tagline { get; set; }
        public string Url { get; set; }
        public string Visibility { get; set; }
    }
    public class TimeLine
    {
        public DateTime DateValue { get; set; }
        public String Title { get; set; }
        public String ToolTip { get; set; }
        public String State { get; set; }
        public String FormatedDateTime { get; set; }

    }
    public class Element
    {
        public string Name { get; set; }
        public string Tagline { get; set; }
        public string Description { get; set; }
        public string Image { get; set; }
        public string Icon { get; set; }

    }

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            LoadVariables();
            LoadContext();
            RenderJsonData();
            RenderContent();
        }
        catch (Exception exc) //Module failed to load
        {

            // DotNetNuke.Services.Exceptions.ProcessModuleLoadException(this, exc);
        }
    }



    #endregion

    #region Optional Interfaces
    public ModuleActionCollection ModuleActions
    {
        get
        {
            var actions = new ModuleActionCollection
                    {
                        {
                            GetNextActionID(), DotNetNuke.Services.Localization.Localization.GetString("EditModule", LocalResourceFile), "", "", "",
                            EditUrl(), false, SecurityAccessLevel.Edit, true, false
                        }
                    };
            return actions;
        }
    }
    #endregion



}




