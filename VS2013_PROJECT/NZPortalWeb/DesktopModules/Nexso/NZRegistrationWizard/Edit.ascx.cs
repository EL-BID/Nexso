
using System.Collections.Generic;
using System;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;


public partial class NZRegistrationWizard_Edit : PortalModuleBase
{

    #region Event Handlers

    override protected void OnInit(EventArgs e)
    {
        InitializeComponent();
        base.OnInit(e);
    }

    private void InitializeComponent()
    {
        this.Load += new System.EventHandler(this.Page_Load);
    }


    private void Page_Load(object sender, System.EventArgs e)
    {
        try
        {

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion


    #region Optional Interfaces

    public ModuleActionCollection ModuleActions
        {
            get
            {
                ModuleActionCollection Actions = new ModuleActionCollection();
                Actions.Add(GetNextActionID(), Localization.GetString("EditModule", this.LocalResourceFile), "", "", "", EditUrl(), false, SecurityAccessLevel.Edit, true, false);
                return Actions;
            }
        }

	#endregion

	}

