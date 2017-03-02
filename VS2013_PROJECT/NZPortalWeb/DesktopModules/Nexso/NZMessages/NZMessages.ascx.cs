
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Http;
using System.Globalization;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Localization;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Entities.Modules;
using Newtonsoft.Json;
using NexsoProBLL;
using NexsoProDAL;

/// <summary>
/// This control is for menssage of people in the Solutions. 
/// https://www.nexso.org/en-us/MyMessages
/// </summary>
public partial class NZMessages : UserUserControlBase, IActionable
{


    #region Private Member Variables
    private int index;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Get from database all conversation related of the user
    /// </summary>
    private void BindData()
    {
        var listMessagesFrom = MessageComponent.GetMessagesFrom(UserInfo.UserID).ToList();
        var usersTo = (from s in listMessagesFrom select s.ToUserId).Distinct();
        var listMessagesTo = MessageComponent.GetMessagesTo(UserInfo.UserID).ToList();
        var usersFrom = (from s in listMessagesTo select s.FromUserId).Distinct();
        var ListUsersConversations = usersFrom.Concat(usersTo).Distinct();
        List<UserProperty> list = new List<UserProperty>();
        foreach (int id in ListUsersConversations)
        {
            UserPropertyComponent userProperty = new UserPropertyComponent(id);
            list.Add(userProperty.UserProperty);
        }
        if (list.Count <= 0)
            noMessageContainer.Visible = true;
        else
            noMessageContainer.Visible = false;

        rpConversations.DataSource = list;
        rpConversations.DataBind();
    }


    /// <summary>
    /// Show message with all data to  the user
    /// </summary>
    /// <param name="list"></param>
    /// <returns></returns>
    private List<MessageUser> FillMessages(List<Message> list)
    {
        List<MessageUser> ListMessageUser = new List<MessageUser>();
        foreach (var item in list)
        {
            UserPropertyComponent userPropertyComponent = new UserPropertyComponent(Convert.ToInt32(item.FromUserId));
            ListMessageUser.Add(new MessageUser
            {
                IdUser = userPropertyComponent.UserProperty.UserId,
                MessageId = (Guid)(item.MessageId),
                FirstName = userPropertyComponent.UserProperty.FirstName,
                Message1 = item.Message1,
                DateCreated = Convert.ToDateTime(item.DateCreated),
                DateRead = Convert.ToDateTime(item.DateRead)
            });
        }
        return ListMessageUser;
    }

    /// <summary>
    /// Get from database all messages  related of the user  (current user and other users who have conversed with the current user)
    /// </summary>
    /// <param name="userId"></param>
    /// <returns></returns>
    private List<Message> GetListMessagesForUser(int userId)
    {

        var list1 = MessageComponent.GetMessages(UserInfo.UserID, userId).ToList();
        var list2 = MessageComponent.GetMessages(userId, UserInfo.UserID).ToList();
        var listFinallyMessages = list1.Concat(list2).OrderBy(p => p.DateCreated).ToList();

        return listFinallyMessages;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="lang"></param>
    /// <returns>Return the user laguage</returns>
    private string getUserLanguage(int lang)
    {
        switch (lang)
        {
            case 1:
                return "en-US";
            case 2:
                return "es-ES";
            case 3:
                return "pt-BR";
            default:
                return "en-US";
        }
    }

    /// <summary>
    /// Avatar image (imagen per user)
    /// </summary>
    /// <param name="userId"></param>
    /// <returns></returns>
    public string imageUrl(int userId)
    {
        UserInfo userTo = UserController.GetUserById(PortalId, userId);
        string urlImage = "/images/no_avatar.gif";
        if (userTo != null)
        {
            string PhotoURL = userTo.Profile.PhotoURL;

            if (!string.IsNullOrEmpty(PhotoURL))

                return PhotoURL;

            else
                return urlImage;
        }


        return urlImage;
    }

    /// <summary>
    /// Registers the client script with the Page object using a key and a URL, which enables the script to be called from the client.
    /// </summary>
    private void RegisterScripts()
    {

        Page.ClientScript.RegisterClientScriptInclude(
             this.GetType(), "NZMessages", ControlPath + "js/NZMessages.js");

        string script = "<script>" +


             "var hFSelector = '" + hFSelector.ClientID + "';"



        + "</script>";


        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Script22", script);

    }
    #endregion

    #region Constructors



    #endregion

    #region Public Properties



    #endregion

    #region Public Methods



    #endregion

    #region Subclasses
    private class MessageUser
    {

        public int IdUser { get; set; }
        public Guid MessageId { get; set; }
        public string FirstName { get; set; }
        public string Message1 { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime DateRead { get; set; }
    }

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            index = 0;
            RegisterScripts();
            BindData();
        }

    }
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        string FileName = System.IO.Path.GetFileNameWithoutExtension(this.AppRelativeVirtualPath);
        if (this.ID != null)
            //this will fix it when its placed as a ChildUserControl 
            this.LocalResourceFile = this.LocalResourceFile.Replace(this.ID, FileName);
        else
            // this will fix it when its dynamically loaded using LoadControl method 
            this.LocalResourceFile = this.LocalResourceFile + FileName + ".ascx.resx";
    }


    /// <summary>
    /// Load messages in repeater
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void rpConversations_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {

        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            var ToUserId = (HiddenField)e.Item.FindControl("hfId");


            Repeater rpMessages = (Repeater)(e.Item.FindControl("rpMessages"));

            //Show messages
            var listMessages = FillMessages(GetListMessagesForUser(Convert.ToInt32(ToUserId.Value)));
            rpMessages.DataSource = listMessages;
            rpMessages.DataBind();


            TextBox txtMessage = (TextBox)e.Item.FindControl("txtMessage");
            Button btnSendMessage = (Button)e.Item.FindControl("btnSendMessage");

            if (btnSendMessage != null)
            {
                btnSendMessage.Attributes.Add("onclick", "getIndexAccordion();");
            }
            if (txtMessage != null)
            {
                txtMessage.Attributes.Add("onKeyPress", "doClick('" + btnSendMessage.ClientID + "',event)");
            }

        }


    }


    /// <summary>
    /// Send message to the other user
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSendMessage_Click(object sender, EventArgs e)
    {
        try
        {
            Button button = (Button)sender;
            var txtMessage = (TextBox)button.Parent.FindControl("txtMessage");
            if (!string.IsNullOrEmpty(txtMessage.Text))
            {
                var ToUserId = button.CommandArgument;    
                Repeater rpMessages = (Repeater)button.Parent.FindControl("rpMessages");
                MessageComponent messageComponent = new MessageComponent();
                // verify that the message doesn't have script and styles
                messageComponent.Message.Message1 = ValidateSecurity.ValidateString(txtMessage.Text, false);
                messageComponent.Message.DateCreated = DateTime.Now;
                messageComponent.Message.FromUserId = UserInfo.UserID;
                messageComponent.Message.ToUserId = Convert.ToInt32(ValidateSecurity.ValidateString(ToUserId, false));

                //Save message in the database
                if (messageComponent.Save() > -1)
                {
                    var list = FillMessages(GetListMessagesForUser(Convert.ToInt32(ValidateSecurity.ValidateString(ToUserId, false))));
                    rpMessages.DataSource = list;
                    rpMessages.DataBind();
                    txtMessage.Text = string.Empty;
                    UserPropertyComponent userPropertyComponent = new UserPropertyComponent(Convert.ToInt32(ToUserId));
                    UserInfo userTo = UserController.GetUserById(PortalId, userPropertyComponent.UserProperty.UserId);
                    UserPropertyComponent userProperty = new UserPropertyComponent(UserInfo.UserID);

                    //Send message
                    try
                    {
                        CultureInfo language = new CultureInfo(getUserLanguage(userPropertyComponent.UserProperty.Language.GetValueOrDefault(1)));
                        DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                  userTo.Email,
                                                                 string.Format(
                                                                      Localization.GetString("MessageTitle", LocalResourceFile, language.Name),
                                                                      userProperty.UserProperty.FirstName + " " + userProperty.UserProperty.LastName
                                                                   ),

                                                                      Localization.GetString("MessageBody", LocalResourceFile, language.Name).Replace("{MESSAGE:Body}",
                                                                     messageComponent.Message.Message1).Replace("{MESSAGE:ViewLink}",
                                                                     NexsoHelper.GetCulturedUrlByTabName("MyMessages"))
                                                                     );
                    }
                    catch (Exception ex)
                    {
                        Exceptions.ProcessModuleLoadException(this, ex);
                    }
                }

            }
        }
        catch (Exception exc)
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
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