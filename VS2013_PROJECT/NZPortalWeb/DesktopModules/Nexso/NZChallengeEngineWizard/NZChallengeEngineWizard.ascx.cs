using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Xml;
using System.Text.RegularExpressions;
using System.Threading;
using Formatting = System.Xml.Formatting;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Security.Permissions;
using DotNetNuke.Entities.Modules.Definitions;
using DotNetNuke.Services.Localization;
using Telerik.Web.UI;
using NexsoProDAL;
using NexsoProBLL;
using DotNetNuke.Services.Exceptions;

/// <summary>
/// This control is for get information user the challenge and safe data BD.
/// https://www.nexso.org/en-us/Backend/ChallengeEngine
/// Note: 1) this control create Url and save in dataBase, but if no containt title, the sistem no generel URL.
/// </summary>
public partial class NZChallengeEngineWizard : PortalModuleBase, IActionable
{
    #region Private Member Variables
    private ChallengeComponent challengeComponent;
    private ChallengeCustomDataComponent challengeCustomDataComponent;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Load the text and style of the buttons and titles 
    /// </summary>
    /// <param name="step">Step in wizard</param>
    private void SetupWizard(int? step)
    {
        wizardChallengeEngine.StartNextButtonStyle.CssClass = "btn step-start";
        wizardChallengeEngine.CancelButtonStyle.CssClass = "btn step-cancel";
        wizardChallengeEngine.StepPreviousButtonStyle.CssClass = "btn step-back";
        wizardChallengeEngine.FinishCompleteButtonStyle.CssClass = "btn step-finish";
        wizardChallengeEngine.StepNextButtonStyle.CssClass = "btn step-forward";
        wizardChallengeEngine.FinishPreviousButtonStyle.CssClass = "btn step-back";
        wizardChallengeEngine.StartNextButtonText = Localization.GetString("Start",
                                                             LocalResourceFile);
        wizardChallengeEngine.FinishPreviousButtonText = Localization.GetString("Previous",
                                                                  LocalResourceFile);
        wizardChallengeEngine.StepNextButtonText = Localization.GetString("Next",
                                                            LocalResourceFile);
        wizardChallengeEngine.StepPreviousButtonText = Localization.GetString("Previous",
                                                                LocalResourceFile);
        wizardChallengeEngine.FinishCompleteButtonText = Localization.GetString("Publish",
                                                                  LocalResourceFile);
        wizardChallengeEngine.CancelButtonText = Localization.GetString("Cancel",
                                                          LocalResourceFile);
        WizardStep0.Title = Localization.GetString("Step0",
                                                  LocalResourceFile);
        WizardStep1.Title = Localization.GetString("Step1",
                                                   LocalResourceFile);
        WizardStep2.Title = Localization.GetString("Step2",
                                                   LocalResourceFile);
        WizardStep3.Title = Localization.GetString("Step3",
                                                   LocalResourceFile);
        WizardStep4.Title = Localization.GetString("Step4",
                                                  LocalResourceFile);
        WizardStep5.Title = Localization.GetString("Step5",
                                                   LocalResourceFile);
        WizardStep6.Title = Localization.GetString("Step6",
                                                   LocalResourceFile);
        WizardStep7.Title = Localization.GetString("Step7",
                                                  LocalResourceFile);
        WizardStep8.Title = Localization.GetString("Step8",
                                                  LocalResourceFile);
        WizardStep9.Title = Localization.GetString("Step9",
                                                  LocalResourceFile);
        WizardStep10.Title = Localization.GetString("Step10",
                                                LocalResourceFile);
        wizardChallengeEngine.ActiveStepIndex = step ?? default(int);

    }

    /// <summary>
    /// Add diferentes list of to dropdownlist typecontrols(checkbox, text), language(en, es, pr) and flavor()
    /// </summary>
    private void BindData()
    {
        SetupWizard(0);

        var list = ListComponent.GetListPerCategory("Language", Thread.CurrentThread.CurrentCulture.Name).ToList();

        rdLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdLanguage.DataSource = list;
        rdLanguage.DataBind();

        list = ListComponent.GetListPerCategory("Flavor", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdSolutionFlavor.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdSolutionFlavor.DataSource = list;
        rdSolutionFlavor.DataBind();


        list = ListComponent.GetListPerCategory("TypeControl", Thread.CurrentThread.CurrentCulture.Name).ToList();
        ddTypeControl.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddTypeControl.DataSource = list;
        ddTypeControl.DataBind();



        FillDataDDChallenge();

        challengeFile.BindData();


    }

    /// <summary>
    /// Load the content of the all pages of the challenge. The content is Title, TagLine, Content and XML (optional).
    /// </summary>
    /// <param name="challengeReference"></param>
    /// <param name="language"></param>
    private void FillDataPage(string challengeReference, string language)
    {
        challengeCustomDataComponent = new ChallengeCustomDataComponent(challengeReference, language);

        var customId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
        if (customId == Guid.Empty)
            customId = Guid.NewGuid();

        if (!string.IsNullOrEmpty(challengeComponent.Challenge.Flavor))
            rdSolutionFlavor.SelectedValue = challengeComponent.Challenge.Flavor;

        var list = GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate);
        FillDataELIGIBILITY(list);
        txtChallengeTitle.Text = challengeCustomDataComponent.ChallengeCustomData.Title;


        ChallengePageComponent challengePageComponent = new ChallengePageComponent(customId, "home");
        txtTitle.Text = challengePageComponent.ChallengePage.Title;
        txtTagLineHome.Text = challengePageComponent.ChallengePage.Tagline;

        txtDescriptionHome.Content = challengePageComponent.ChallengePage.Description;


        challengePageComponent = new ChallengePageComponent(customId, "criteria");
        txtCriteriaTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        teCriteriaContent.Content = challengePageComponent.ChallengePage.Content;
        txtTitleCriteria.Text = challengePageComponent.ChallengePage.Title;


        challengePageComponent = new ChallengePageComponent(customId, "judges");
        txtJudgesTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        txtTitleJudges.Text = challengePageComponent.ChallengePage.Title;
        list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);
        FillDataJUDGE(list);

        challengePageComponent = new ChallengePageComponent(customId, "partners");
        txtPartnersTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        txtTitlePartners.Text = challengePageComponent.ChallengePage.Title;
        list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);
        FillDataPARTNER(list);


        challengePageComponent = new ChallengePageComponent(customId, "faq");
        txtFAQTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        txtTitleFAQ.Text = challengePageComponent.ChallengePage.Title;
        list = GetListFAQ(challengePageComponent.ChallengePage.Content);
        FillDataFAQ(list);

        challengePageComponent = new ChallengePageComponent(customId, "terms");
        txtTermsTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        txtTitleTerms.Text = challengePageComponent.ChallengePage.Title;
        teTermsContent.Content = challengePageComponent.ChallengePage.Content;


        challengePageComponent = new ChallengePageComponent(customId, "rules");
        txtParticipateTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        txtTitleParticipate.Text = challengePageComponent.ChallengePage.Title;
        teParticipateContent.Content = challengePageComponent.ChallengePage.Content;

        challengePageComponent = new ChallengePageComponent(customId, "awards");
        txtAwardsTagLine.Text = challengePageComponent.ChallengePage.Tagline;
        txtTitleAwards.Text = challengePageComponent.ChallengePage.Title;

        teAwardsContent.Content = challengePageComponent.ChallengePage.Content;


        challengePageComponent = new ChallengePageComponent(customId, "scoring");
        txtTitleScoring.Text = challengePageComponent.ChallengePage.Title;

        FillDataRepeaterPage(challengeComponent.Challenge.ChallengeReference);
        BindDataDictionary(GetListDictionary(challengeCustomDataComponent.ChallengeCustomData.Tags));
        grdDictionary.DataBind();



    }

    /// <summary>
    /// Load the list of the pages in the step finish, page name and page url in english, spanish, and portuguese.
    /// </summary>
    /// <param name="ChallengeReference"></param>
    private void FillDataRepeaterPage(string ChallengeReference)
    {
        List<ListGeneric> listPage = new List<ListGeneric>();
        ChallengeCustomDataComponent customData = new ChallengeCustomDataComponent(ChallengeReference, "en-US");
        var ListPageEn = ChallengePageComponent.GetPagesForCustomData(customData.ChallengeCustomData.ChallengeCustomDatalId).OrderBy(x => x.Order);

        customData = new ChallengeCustomDataComponent(ChallengeReference, "es-ES");
        var ListPageEs = ChallengePageComponent.GetPagesForCustomData(customData.ChallengeCustomData.ChallengeCustomDatalId).OrderBy(x => x.Order);

        customData = new ChallengeCustomDataComponent(ChallengeReference, "pt-BR");
        var ListPagePt = ChallengePageComponent.GetPagesForCustomData(customData.ChallengeCustomData.ChallengeCustomDatalId).OrderBy(x => x.Order);


        foreach (var item in ListPageEn)
        {
            var pageEs = ListPageEs.FirstOrDefault(x => x.Reference == item.Reference);
            var pagePt = ListPagePt.FirstOrDefault(x => x.Reference == item.Reference);

            var urlEs = string.Empty;
            var urlPt = string.Empty;
            if (pageEs != null && pageEs.Url != null)
                urlEs = pageEs.Url;
            if (pagePt != null && pagePt.Url != null)
                urlPt = pagePt.Url;


            if (item.Title != string.Empty)
            {
                ListGeneric itemList = new ListGeneric();
                itemList.id = item.Reference;
                itemList.value1 = item.Reference;
                itemList.value2 = item.Url != null ? item.Url : string.Empty;
                itemList.value3 = urlEs;
                itemList.value4 = urlPt;

                listPage.Add(itemList);
            }
        }

        rpPages.DataSource = listPage.ToList();
        rpPages.DataBind();

    }

    /// <summary>
    /// Save URL per page, if page exist
    /// </summary>
    /// <param name="challengePageComponent"></param>
    /// <param name="url"></param>
    /// <param name="swUrl"></param>
    /// <param name="isHome"></param>
    private void SaveUrl(ChallengePageComponent challengePageComponent, string url, bool swUrl, bool isHome)
    {

        if (challengePageComponent.ChallengePage.ChallengeCustomDataId != Guid.Empty)
        {
            if (swUrl)
            {
                if (isHome)
                    challengePageComponent.ChallengePage.Url = url;
                else
                {
                    if (!string.IsNullOrEmpty(challengePageComponent.ChallengePage.Title))
                        challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                    else
                        challengePageComponent.Delete();

                }
            }


            challengePageComponent.Save();
        }
    }


    /// <summary>
    /// Write XML of the differents ítems (criteria, judges, PARTNER, FAQ)
    /// </summary>
    /// <param name="list"></param>
    /// <param name="page"></param>
    /// <returns></returns>
    private string XML(List<ListGeneric> list, string page)
    {

        string xmlString = null;
        using (StringWriter sw = new StringWriter())
        {
            XmlTextWriter writer = new XmlTextWriter(sw);

            writer.Formatting = Formatting.None; // if you want it indented
            writer.WriteStartDocument(); // <?xml version="1.0" encoding="utf-16"?>
            writer.WriteStartElement("FIELDS"); //<TAG>
            var count = 1;
            foreach (var item in list)
            {

                writer.WriteStartElement("FIELD");
                writer.WriteStartElement("ID");
                writer.WriteString(item.id.ToString());
                writer.WriteEndElement();
                if (page == "judge" || page == "partners")
                {
                    writer.WriteStartElement("PHOTO");
                    writer.WriteString(item.value3);
                    writer.WriteEndElement();
                    writer.WriteStartElement("NAME");
                    writer.WriteString(item.value1);
                    writer.WriteEndElement();
                    writer.WriteStartElement("TAGLINE");
                    writer.WriteString(item.value4);
                    writer.WriteEndElement();
                    writer.WriteStartElement("DESCRIPTION");
                    writer.WriteString(item.value2);
                    writer.WriteEndElement();
                    writer.WriteStartElement("POSITION");
                    writer.WriteString(count.ToString());
                    writer.WriteEndElement();
                    writer.WriteStartElement("TAG");
                    writer.WriteString(item.value5);
                    writer.WriteEndElement();
                }
                else
                {
                    if (page == "faq")
                    {
                        writer.WriteStartElement("QUESTION");
                        writer.WriteString(item.value1);
                        writer.WriteEndElement();
                        writer.WriteStartElement("ANSWER");
                        writer.WriteString(item.value2);
                        writer.WriteEndElement();
                        writer.WriteStartElement("POSITION");
                        writer.WriteString(count.ToString());
                        writer.WriteEndElement();
                        writer.WriteStartElement("TAG");
                        writer.WriteString(item.value3);
                        writer.WriteEndElement();
                    }
                    else
                    {
                        if (page == "eligibility")
                        {
                            writer.WriteStartElement("TYPE");
                            writer.WriteString(item.value1);
                            writer.WriteEndElement();
                            writer.WriteStartElement("TEXT");
                            writer.WriteString(item.value2);
                            writer.WriteEndElement();
                            writer.WriteStartElement("POSITION");
                            writer.WriteString(count.ToString());
                            writer.WriteEndElement();
                        }
                        else
                        {
                            if (page == "dictionary")
                            {
                                writer.WriteStartElement("KEY");
                                writer.WriteString(item.value1);
                                writer.WriteEndElement();
                                writer.WriteStartElement("VALUE");
                                writer.WriteString(item.value2);
                                writer.WriteEndElement();
                            }


                        }
                    }
                }

                writer.WriteEndElement();
                count++;

            }
            writer.WriteEndElement();
            writer.WriteEndDocument();
            xmlString = sw.ToString();
            return xmlString;

        }

    }
    private string FormatText(string strHtml)
    {
        string strText = strHtml;
        try
        {
            if (!String.IsNullOrEmpty(strText))
            {
                strText = HtmlUtils.StripWhiteSpace(strText, true);
                strText = HtmlUtils.FormatText(strText, false);
            }
        }
        catch (Exception exc) //Module failed to load
        {
        }

        return strText;
    }
    private string FormatHtml(string strText)
    {

        string strHtml = strText;
        try
        {
            if (!String.IsNullOrEmpty(strHtml))
            {
                strHtml = strHtml.Replace("\r", "");
                strHtml = strHtml.Replace("\n", "<br />");
            }
        }
        catch (Exception exc) //Module failed to load
        {
        }
        return strHtml;
    }

    /// <summary>
    /// ADD, EDIT or DELETE FAQ in the wizard. This method also modifies the XML
    /// </summary>
    /// <param name="action"></param>
    /// <param name="id"></param>
    private void ActionsFAQ(string action, string id)
    {
        try
        {
            challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
            ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "faq");

            var list = GetListFAQ(challengePageComponent.ChallengePage.Content);
            var listFaq = list;
            ListGeneric faqEdit = null;
            if (action == "EDIT")
            {
                faqEdit = list.FirstOrDefault(a => a.id == id);
                listFaq = list.Where(a => a.id != id).ToList();
            }

            if (action == "DELETE")
                listFaq = list.Where(a => a.id != id).ToList();

            var sw = false;
            if (action == "ADD" || action == "EDIT")
            {
                var ID = Guid.NewGuid().ToString();
                var position = listFaq.Count + 1;
                if (action == "EDIT")
                {
                    ID = faqEdit.id;
                    position = faqEdit.position;

                }
                listFaq.Add(new ListGeneric { id = ID, value1 = txtFAQuestion.Text, value2 = txtFAQAnswer.Content, value3 = txtTagFAQ.Text, position = position });

                sw = true;
            }
            if (sw || id == idEditItemFAQ.Value)
            {
                txtFAQuestion.Text = string.Empty;
                txtFAQAnswer.Content = string.Empty;
                txtTagFAQ.Text = string.Empty;
            }
            var xmlstring = XML(listFaq.OrderBy(x => x.position).ToList(), "faq");


            if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
            {
                challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                challengePageComponent.ChallengePage.Title = "faq";
                challengePageComponent.ChallengePage.Reference = "faq";
                challengePageComponent.ChallengePage.Order = 4;
            }
            challengePageComponent.ChallengePage.Content = xmlstring;
            challengePageComponent.ChallengePage.ContentType = "XML";

            challengePageComponent.Save();

            FillDataFAQ(GetListFAQ(challengePageComponent.ChallengePage.Content));

        }
        catch
        {

        }
    }

    /// <summary>
    /// ADD, EDIT or DELETE JUDGE in the wizard. This method also modifies the XML
    /// </summary>
    /// <param name="action"></param>
    /// <param name="id"></param>
    private void ActionsJUDGE(string action, string id)
    {
        try
        {
            challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
            ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "judges");


            var list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);
            var listJudges = list;
            ListGeneric judgeEdit = null;
            if (action == "EDIT")
            {
                judgeEdit = list.FirstOrDefault(a => a.id == id);
                listJudges = list.Where(a => a.id != id).ToList();
            }

            if (action == "DELETE")
            {

                judgeEdit = list.FirstOrDefault(a => a.id == id);
                string pathServer = Server.MapPath(judgeEdit.value3);
                if (System.IO.File.Exists(pathServer))
                    System.IO.File.Delete(pathServer);


                listJudges = list.Where(a => a.id != id).ToList();
            }
            bool sw = false;
            if (action == "ADD" || action == "EDIT")
            {
                var ID = Guid.NewGuid().ToString();
                var position = listJudges.Count + 1;
                var pathPhoto = hfPhoto.Value;
                if (action == "EDIT")
                {
                    ID = judgeEdit.id;
                    position = judgeEdit.position;
                    if (string.IsNullOrEmpty(pathPhoto))
                        pathPhoto = judgeEdit.value3;
                }
                listJudges.Add(new ListGeneric { id = ID, value1 = txtNameJudge.Text, value2 = txtDescriptionJudge.Content, value3 = pathPhoto, value4 = txtTagLineJudge.Text, position = position, value5 = txtTagJudge.Text });
                sw = true;
            }
            if (sw || id == idEditItemJudge.Value)
            {
                hfPhoto.Value = string.Empty;
                txtNameJudge.Text = string.Empty;
                txtDescriptionJudge.Content = string.Empty;
                lblPhotoEdit.Visible = true;
                lblPhotoEdit.Text = string.Empty;
                txtTagLineJudge.Text = string.Empty;
                txtTagJudge.Text = string.Empty;

            }
            var xmlstring = XML(listJudges.OrderBy(x => x.position).ToList(), "judge");
            if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
            {
                challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                challengePageComponent.ChallengePage.Title = "judges";
                challengePageComponent.ChallengePage.Reference = "judges";
                challengePageComponent.ChallengePage.Order = 2;
            }
            challengePageComponent.ChallengePage.Content = xmlstring;
            challengePageComponent.ChallengePage.ContentType = "XML";

            challengePageComponent.Save();

            FillDataJUDGE(GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content));


        }
        catch
        {
        }
    }

    /// <summary>
    /// ADD, EDIT or DELETE ELIGIBILITY in the wizard. This method also modifies the XML
    /// </summary>
    /// <param name="action"></param>
    /// <param name="id"></param>
    private void ActionsELIGIBILITY(string action, string id)
    {
        try
        {
            challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);



            var list = GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate);
            var listELI = list;
            ListGeneric ELIEdit = null;
            if (action == "EDIT")
            {
                ELIEdit = list.FirstOrDefault(a => a.id == id);
                listELI = list.Where(a => a.id != id).ToList();
            }

            if (action == "DELETE")
                listELI = list.Where(a => a.id != id).ToList();

            var sw = false;
            if (action == "ADD" || action == "EDIT")
            {
                var ID = Guid.NewGuid().ToString();
                var position = listELI.Count + 1;

                if (action == "EDIT")
                {
                    position = ELIEdit.position;
                    ID = ELIEdit.id;
                }
                listELI.Add(new ListGeneric { id = ID, value1 = ddTypeControl.Text, value2 = txtEligibility.Text, position = position });

                ddTypeControl.SelectedValue = string.Empty;
                txtEligibility.Text = string.Empty;
                ddTypeControl.ClearSelection();
                ddTypeControl.Text = string.Empty;
                sw = true;
            }
            if (sw || id == idEditItemEligibility.Value)
            {
                ddTypeControl.SelectedValue = string.Empty;
                txtEligibility.Text = string.Empty;
                ddTypeControl.ClearSelection();
                ddTypeControl.Text = string.Empty;
            }

            var xmlstring = XML(listELI.OrderBy(x => x.position).ToList(), "eligibility");


            if (challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId == Guid.Empty)
            {
                challengeCustomDataComponent.ChallengeCustomData.Language = rdLanguage.SelectedValue;
                challengeCustomDataComponent.ChallengeCustomData.ChallengeReference = rdChallengeReference.SelectedValue;
            }
            challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate = xmlstring;
            challengeCustomDataComponent.Save();

            FillDataELIGIBILITY(GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate));

        }
        catch
        {

        }
    }

    /// <summary>
    /// ADD, EDIT or DELETE PARTNER in the wizard. This method also modifies the XML
    /// </summary>
    /// <param name="action"></param>
    /// <param name="id"></param>
    private void ActionsPARTNER(string action, string id)
    {
        try
        {
            challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
            ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "partners");


            var list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);
            var listPartners = list;
            ListGeneric partnerEdit = null;
            if (action == "EDIT")
            {
                partnerEdit = list.FirstOrDefault(a => a.id == id);
                listPartners = list.Where(a => a.id != id).ToList();
            }

            if (action == "DELETE")
            {

                partnerEdit = list.FirstOrDefault(a => a.id == id);
                string pathServer = Server.MapPath(partnerEdit.value3);
                if (System.IO.File.Exists(pathServer))
                    System.IO.File.Delete(pathServer);


                listPartners = list.Where(a => a.id != id).ToList();
            }
            bool sw = false;
            if (action == "ADD" || action == "EDIT")
            {
                var ID = Guid.NewGuid().ToString();
                var position = listPartners.Count + 1;
                var pathPhoto = hfImage.Value;
                if (action == "EDIT")
                {
                    ID = partnerEdit.id;
                    position = partnerEdit.position;
                    if (string.IsNullOrEmpty(pathPhoto))
                        pathPhoto = partnerEdit.value3;
                }
                listPartners.Add(new ListGeneric { id = ID, value1 = txtNamePartner.Text, value2 = txtDescriptionPartner.Content, value3 = pathPhoto, value4 = txtTagLinePartner.Text, position = position, value5 = txtTagPartner.Text });
                sw = true;
            }
            if (sw || id == hfPartners.Value)
            {
                hfImage.Value = string.Empty;
                txtNamePartner.Text = string.Empty;
                txtDescriptionPartner.Content = string.Empty;
                lblImageEdit.Visible = true;
                lblImageEdit.Text = string.Empty;
                txtTagPartner.Text = string.Empty;
                txtTagLinePartner.Text = string.Empty;

            }
            var xmlstring = XML(listPartners.OrderBy(x => x.position).ToList(), "partners");
            if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
            {
                challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                challengePageComponent.ChallengePage.Title = "partners";
                challengePageComponent.ChallengePage.Reference = "partners";
                challengePageComponent.ChallengePage.Order = 3;
            }
            challengePageComponent.ChallengePage.Content = xmlstring;
            challengePageComponent.ChallengePage.ContentType = "XML";

            challengePageComponent.Save();

            FillDataPARTNER(GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content));


        }
        catch
        {

        }
    }

    /// <summary>
    /// Get the custom pages from challengePageComponent and create the pages in DNN
    /// </summary>
    /// <param name="challengeReference"></param>
    /// <param name="language"></param>
    /// <param name="listSplit"></param>
    private void GetCustomPage(string challengeReference, string language, string[] listSplit)
    {
        ChallengeCustomDataComponent customData = new ChallengeCustomDataComponent(challengeReference, language);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(customData.ChallengeCustomData.ChallengeCustomDatalId, "home");

        if (challengePageComponent.ChallengePage.ChallengeCustomDataId != Guid.Empty)
        {
            GeneratePage(challengePageComponent, customData.ChallengeCustomData.Title, true, language, 0);
        }

        ChallengePageComponent challengePageComponentHome = new ChallengePageComponent(customData.ChallengeCustomData.ChallengeCustomDatalId, "home");
        foreach (var item in listSplit)
        {
            if (item != string.Empty)
            {
                challengePageComponent = new ChallengePageComponent(customData.ChallengeCustomData.ChallengeCustomDatalId, item);
                if (!string.IsNullOrEmpty(challengePageComponent.ChallengePage.Url))
                {
                    if (challengePageComponent.ChallengePage.Reference != "home")
                        GeneratePage(challengePageComponent, customData.ChallengeCustomData.Title, false, language, Convert.ToInt32(challengePageComponentHome.ChallengePage.TabID));

                }
            }
        }
    }

    /// <summary>
    /// Get the custom pages from challengePageComponent and add information to the pages (tabs) in DNN
    /// </summary>
    /// <param name="challengeReference"></param>
    /// <param name="language"></param>
    /// <param name="listSplit"></param>
    /// <param name="listOtherLanguage"></param>
    private void GetCustomPageUrls(string challengeReference, string language, string[] listSplit, List<string> listOtherLanguage)
    {
        ChallengeCustomDataComponent customData = new ChallengeCustomDataComponent(challengeReference, language);
        foreach (var item in listSplit)
        {
            List<ChallengePage> list = new List<ChallengePage>();

            foreach (var item2 in listOtherLanguage)
            {
                ChallengeCustomDataComponent customData2 = new ChallengeCustomDataComponent(challengeReference, item2);
                if (customData2 != null)
                {
                    ChallengePageComponent challengePage = new ChallengePageComponent(customData2.ChallengeCustomData.ChallengeCustomDatalId, item);
                    list.Add(challengePage.ChallengePage);
                }
            }

            ChallengePageComponent challengePageComponent = new ChallengePageComponent(customData.ChallengeCustomData.ChallengeCustomDatalId, item);

            SetUrlsPage(list, language, Convert.ToInt32(challengePageComponent.ChallengePage.TabID));

        }
    }

    /// <summary>
    /// This method generates pages in DNN using DNN TabController class. Also adds roles to pages and the module NZChallengePage
    /// </summary>
    /// <param name="challengePageComponent"></param>
    /// <param name="parentTabReference"></param>
    /// <param name="isHome"></param>
    /// <param name="language"></param>
    /// <param name="id"></param>
    private void GeneratePage(ChallengePageComponent challengePageComponent, string parentTabReference, bool isHome, string language, int id)
    {
        try
        {
            if (Convert.ToInt32(challengePageComponent.ChallengePage.TabID) <= 0)
            {
                PortalSettings portalSettings = new PortalSettings(PortalController.GetCurrentPortalSettings().PortalId);
                int portalId = portalSettings.PortalId;
                string defaultPortalSkin = portalSettings.DefaultPortalSkin;
                string defaultPortalContainer = portalSettings.DefaultPortalContainer;
                TabController tabController = new TabController();

                Locale locale = LocaleController.Instance.GetLocale(language);
                TabInfo parentTab = tabController.GetTabByName("c", portalId);

                if (!isHome)
                {
                    parentTab = tabController.GetTabByCulture(id, portalId, locale);
                }
                if (parentTab != null)
                {

                    TabInfo tab = new TabInfo();
                    tab.PortalID = portalId;
                    if (!isHome)
                    {
                        tab.TabName = challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        tab.Title = challengePageComponent.ChallengePage.Title;
                        tab.Description = challengePageComponent.ChallengePage.Title;
                        tab.KeyWords = challengePageComponent.ChallengePage.Title;
                    }
                    else
                    {
                        tab.TabName = parentTabReference.Replace(" ", "");
                        tab.Title = parentTabReference;
                        tab.Description = parentTabReference;
                        tab.KeyWords = parentTabReference;
                    }
                    tab.IsVisible = true;
                    tab.DisableLink = false;
                    tab.ParentId = parentTab.TabID;
                    tab.IsDeleted = false;
                    tab.Url = "";
                    tab.SkinSrc = defaultPortalSkin;
                    tab.ContainerSrc = defaultPortalContainer;
                    tab.IsSuperTab = false;
                    tab.CultureCode = parentTab.CultureCode;


                    //Add permission to the page 
                    foreach (PermissionInfo p in PermissionController.GetPermissionsByTab())
                    {
                        if (p.PermissionKey == "VIEW")
                        {
                            TabPermissionInfo tpi = new TabPermissionInfo();
                            tpi.PermissionID = p.PermissionID;
                            tpi.PermissionKey = p.PermissionKey;
                            tpi.PermissionName = p.PermissionName;
                            tpi.AllowAccess = true;
                            tpi.RoleID = -1; //ID of all users
                            tab.TabPermissions.Add(tpi);
                        }
                        if (p.PermissionCode == "SYSTEM_TAB")
                        {

                            TabPermissionInfo tpi = new TabPermissionInfo();
                            tpi.PermissionID = p.PermissionID;
                            tpi.PermissionKey = p.PermissionKey;
                            tpi.PermissionName = p.PermissionName;
                            tpi.AllowAccess = true;
                            tpi.RoleID = 10;
                            tab.TabPermissions.Add(tpi);

                        }
                    }


                    int tabId = tabController.AddTab(tab, true);
                    challengePageComponent.ChallengePage.TabID = tabId;
                    challengePageComponent.Save();


                    DataCache.ClearModuleCache(tab.TabID);

                    tabController.AddMissingLanguages(portalId, tab.TabID);

                }
            }
        }
        catch { }

    }

    /// <summary>
    /// Create and set URL to DNN pages
    /// </summary>
    /// <param name="listPage"></param>
    /// <param name="language"></param>
    /// <param name="id"></param>
    private void SetUrlsPage(List<ChallengePage> listPage, string language, int id)
    {
        try
        {
            TabController tabController = new TabController();

            foreach (var item in listPage)
            {
                Locale locale = LocaleController.Instance.GetLocale(item.ChallengeCustomData.Language);
                TabInfo tab = tabController.GetTabByCulture(id, PortalController.GetCurrentPortalSettings().PortalId, locale);
                if (tab != null)
                {
                    ChallengePageComponent challengePage = new ChallengePageComponent(item.ChallengePageId);
                    if (challengePage.ChallengePage.Reference != "home")
                    {
                        tab.TabName = challengePage.ChallengePage.Title.Replace(" ", "");
                        tab.Title = challengePage.ChallengePage.Title;
                        tab.Description = challengePage.ChallengePage.Title;
                        tab.KeyWords = challengePage.ChallengePage.Title;
                    }
                    else
                    {
                        tab.TabName = challengePage.ChallengePage.ChallengeCustomData.Title.Replace(" ", "");
                        tab.Title = challengePage.ChallengePage.ChallengeCustomData.Title;
                        tab.Description = challengePage.ChallengePage.ChallengeCustomData.Title;
                        tab.KeyWords = challengePage.ChallengePage.ChallengeCustomData.Title;
                    }
                    tab.IsVisible = true;

                    TabPermissionCollection permissions = tab.TabPermissions;
                    //Add permission to the page so that all users can view it
                    foreach (PermissionInfo p in PermissionController.GetPermissionsByTab())
                    {
                        if (p.PermissionKey == "VIEW")
                        {
                            TabPermissionInfo tpi = new TabPermissionInfo();
                            tpi.PermissionID = p.PermissionID;
                            tpi.PermissionKey = p.PermissionKey;
                            tpi.PermissionName = p.PermissionName;
                            tpi.AllowAccess = true;
                            tpi.RoleID = -1; //ID of all users

                            var sw = true;
                            foreach (TabPermissionInfo item2 in permissions)
                            {

                                if (item2.PermissionID == tpi.PermissionID)
                                {
                                    sw = false;
                                    break;
                                }

                            }

                            if (sw)
                                tab.TabPermissions.Add(tpi);
                        }

                        if (p.PermissionCode == "SYSTEM_TAB")
                        {

                            TabPermissionInfo tpi = new TabPermissionInfo();
                            tpi.PermissionID = p.PermissionID;
                            tpi.PermissionKey = p.PermissionKey;
                            tpi.PermissionName = p.PermissionName;
                            tpi.AllowAccess = true;
                            tpi.RoleID = 10;

                            var sw = true;
                            foreach (TabPermissionInfo item2 in permissions)
                            {

                                if (item2.PermissionID == tpi.PermissionID)
                                {
                                    sw = false;
                                    break;
                                }

                            }

                            if (sw)
                                tab.TabPermissions.Add(tpi);

                        }
                    }
                    if (item.Reference != "scoring")
                    {
                        ModuleController moduleController = new ModuleController();
                        var getmodules = moduleController.GetTabModules(tab.TabID).ToList();
                        bool sw2 = true;
                        foreach (var item2 in getmodules)
                        {
                            if ((item2.Value.FriendlyName.IndexOf("NZChallengePage") > -1 || item2.Value.ModuleName.IndexOf("NZChallengePage") > -1) && item2.Value.IsDeleted != true)
                            {
                                sw2 = false;
                                break;
                            }
                        }

                        if (sw2)
                        {
                            DesktopModuleInfo desktopModuleInfo = null;

                            foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(PortalController.GetCurrentPortalSettings().PortalId))
                            {
                                DesktopModuleInfo mod = kvp.Value;
                                if (mod != null)
                                    if (mod.FriendlyName.IndexOf("NZChallengePage") > -1 || mod.ModuleName.IndexOf("NZChallengePage") > -1)
                                    {
                                        desktopModuleInfo = mod;
                                        break;
                                    }
                            }

                            if (desktopModuleInfo != null)
                            {
                                foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo.DesktopModuleID).Values)
                                {
                                    ModuleInfo moduleInfo = new ModuleInfo();
                                    moduleInfo.PortalID = PortalController.GetCurrentPortalSettings().PortalId;
                                    moduleInfo.TabID = tab.TabID;
                                    moduleInfo.ModuleOrder = 1;
                                    moduleInfo.ModuleTitle = "NZChallengePage";
                                    moduleInfo.PaneName = "ContentPane";
                                    moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                                    moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;
                                    moduleInfo.InheritViewPermissions = true;
                                    moduleInfo.AllTabs = false;
                                    moduleInfo.Alignment = "";
                                    moduleInfo.CultureCode = tab.CultureCode;

                                    int moduleId = moduleController.AddModule(moduleInfo);

                                }
                            }
                        }
                    }
                    else
                    {
                        if (item.ChallengeCustomData.Language == "en-US")
                        {
                            ModuleController moduleController = new ModuleController();
                            var getmodules = moduleController.GetTabModules(tab.TabID).ToList();
                            bool sw2 = true;
                            foreach (var item2 in getmodules)
                            {
                                if ((item2.Value.FriendlyName.IndexOf("NZReportJudge") > -1 || item2.Value.ModuleName.IndexOf("NZReportJudge") > -1) && item2.Value.IsDeleted != true)
                                {
                                    sw2 = false;
                                    break;
                                }
                            }

                            if (sw2)
                            {
                                DesktopModuleInfo desktopModuleInfo = null;

                                foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(PortalController.GetCurrentPortalSettings().PortalId))
                                {
                                    DesktopModuleInfo mod = kvp.Value;
                                    if (mod != null)
                                        if (mod.FriendlyName.IndexOf("NZReportJudge") > -1 || mod.ModuleName.IndexOf("NZReportJudge") > -1)
                                        {
                                            desktopModuleInfo = mod;
                                            break;
                                        }
                                }

                                if (desktopModuleInfo != null)
                                {
                                    foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo.DesktopModuleID).Values)
                                    {
                                        ModuleInfo moduleInfo = new ModuleInfo();
                                        moduleInfo.PortalID = PortalController.GetCurrentPortalSettings().PortalId;
                                        moduleInfo.TabID = tab.TabID;
                                        moduleInfo.ModuleOrder = 1;
                                        moduleInfo.ModuleTitle = "NZReportJudge";
                                        moduleInfo.PaneName = "ContentPane";
                                        moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                                        moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;
                                        moduleInfo.InheritViewPermissions = true;
                                        moduleInfo.AllTabs = false;
                                        moduleInfo.Alignment = "";
                                        moduleInfo.CultureCode = tab.CultureCode;


                                        int moduleId = moduleController.AddModule(moduleInfo);

                                        var s = string.Empty;
                                        moduleController.UpdateModuleSetting(moduleInfo.ModuleID, "ChallengeReference", item.ChallengeCustomData.ChallengeReference);
                                        if (Settings.Contains("ChallengeReference"))
                                            s = Settings["ChallengeReference"].ToString();
                                    }
                                }
                            }
                        }
                    }

                    tabController.UpdateTab(tab);
                    challengePage.ChallengePage.TabID = tab.TabID;

                    challengePage.Save();
                    tabController.PublishTab(tab);
                }
            }
        }
        catch { }
    }
    #endregion

    #region Public Properties



    #endregion
    /// <summary>
    /// Get XML with FAQ of the challengeGetList
    /// </summary>
    /// <param name="xmlData"></param>
    /// <returns></returns>
    #region Public Methods
    public List<ListGeneric> GetListFAQ(string xmlData)
    {

        List<ListGeneric> list = new List<ListGeneric>();

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

            string QUESTION, ANSWER, ID, POSITION, TAG;


            if (byteArray.Length > 0)
            {
                try
                {

                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {

                        QUESTION = ANSWER = ID = POSITION = TAG = string.Empty;

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

                            if (!string.IsNullOrEmpty(QUESTION) && !string.IsNullOrEmpty(ANSWER))
                            {

                                list.Add(new ListGeneric { id = ID, value1 = QUESTION, value2 = ANSWER, value3 = TAG, position = Convert.ToInt32(POSITION) });

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

    /// <summary>
    /// Load FAQ of the challenge
    /// </summary>
    /// <param name="list"></param>
    public void FillDataFAQ(List<ListGeneric> list)
    {
        rpFAQ.DataSource = list.OrderBy(x => x.position);
        rpFAQ.DataBind();
    }

    /// <summary>
    /// Get XML with JUDGES and PARTNER of the challenge
    /// </summary>
    /// <param name="xmlData"></param>
    /// <returns></returns>
    public List<ListGeneric> GetListJUDGEandPARTNER(string xmlData)
    {

        List<ListGeneric> list = new List<ListGeneric>();

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

                                list.Add(new ListGeneric { id = ID, value1 = NAME, value2 = DESCRIPTION, value3 = PHOTO, value4 = TAGLINE, position = Convert.ToInt32(POSITION), value5 = TAG });

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

    /// <summary>
    /// Load judges of the challenge
    /// </summary>
    /// <param name="list"></param>
    public void FillDataJUDGE(List<ListGeneric> list)
    {

        rpJudges.DataSource = list.OrderBy(x => x.position);
        rpJudges.DataBind();
    }

    /// <summary>
    /// Load challenge selected in dropdownlist challengeReference
    /// </summary>
    /// <param name="challengeReference"></param>
    public void DataChallenge(string challengeReference)
    {
        challengeComponent = new ChallengeComponent(challengeReference);
        if (challengeComponent.Challenge.PreLaunch != null)
            rdPreLaunch.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.PreLaunch);
        if (challengeComponent.Challenge.Launch != null)
            rdLaunch.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.Launch);
        if (challengeComponent.Challenge.EntryFrom != null)
            rdAvailableFrom.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.EntryFrom);
        if (challengeComponent.Challenge.EntryTo != null)
            rdAvailableTo.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.EntryTo);
        if (challengeComponent.Challenge.ScoringL1From != null)
            rdEval1From.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.ScoringL1From);
        if (challengeComponent.Challenge.ScoringL1To != null)
            rdEval1To.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.ScoringL1To);
        if (challengeComponent.Challenge.Closed != null)
            rdClosed.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.Closed);
        hlAdminJudge.NavigateUrl = NexsoHelper.GetCulturedUrlByTabName("AdminJudges") + "/cll/" + challengeComponent.Challenge.ChallengeReference;
        FillDataPage(challengeReference, rdLanguage.SelectedValue);

    }

    /// <summary>
    /// Get XML with Elegibility criteria of the challenge (home page of the challenge)
    /// <param name="xmlData"></param>
    /// <returns></returns>
    public List<ListGeneric> GetListELIGIBILITY(string xmlData)
    {

        List<ListGeneric> list = new List<ListGeneric>();

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
                                StringBuilder str = new StringBuilder();
                                switch (TYPE)
                                {

                                    case "Check":
                                        str.Append("<input type=\"checkbox\" name=\"" + new Guid(ID) + "\" value=\"" + TEXT + "\"> " + TEXT + "</input>");
                                        break;
                                    case "Text":
                                        str.Append("<label> " + TEXT + "</label><input type=\"textbox\" id=\"" + new Guid(ID) + "\"></input>");
                                        break;

                                }
                                list.Add(new ListGeneric { id = ID, value1 = TYPE, value2 = TEXT, value3 = str.ToString(), position = Convert.ToInt32(POSITION) });

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

    /// <summary>
    /// Load elegibility criteria in repeater 
    /// </summary>
    /// <param name="list"></param>
    public void FillDataELIGIBILITY(List<ListGeneric> list)
    {
        if (list.Count == 0)
        {
            rpEligibility.HeaderTemplate = null;
            rpEligibility.FooterTemplate = null;
        }
        rpEligibility.DataSource = list.OrderBy(x => x.position);
        rpEligibility.DataBind();
        HTMLControls(list.OrderBy(x => x.position).ToList());

    }

    /// <summary>
    /// Load Partner in repeater
    /// </summary>
    /// <param name="list"></param>
    public void FillDataPARTNER(List<ListGeneric> list)
    {

        rpPartners.DataSource = list.OrderBy(x => x.position);
        rpPartners.DataBind();
    }

    /// <summary>
    /// Load the dictionary values of the XML,This method is called from  the method FillDataPage (step fisish),
    /// </summary>
    /// <param name="xmlData"></param>
    /// <returns></returns>
    public List<ListGeneric> GetListDictionary(string xmlData)
    {

        List<ListGeneric> list = new List<ListGeneric>();

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

                                list.Add(new ListGeneric { id = ID, value1 = KEY, value2 = VALUE });

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
    /// <summary>
    /// Add class to circle in SideBar= Current is green, previous is blue and next is gray
    /// </summary>
    /// <param name="wizardStep"></param>
    /// <returns></returns>
    protected string GetClassForWizardStep(object wizardStep)
    {
        WizardStep step = wizardStep as WizardStep;

        if (step == null)
        {
            return "";
        }
        int stepIndex = wizardChallengeEngine.WizardSteps.IndexOf(step);

        if (stepIndex < wizardChallengeEngine.ActiveStepIndex)
        {
            return "prevStep";
        }
        else if (stepIndex > wizardChallengeEngine.ActiveStepIndex)
        {
            return "nextStep";
        }
        else
        {
            return "currentStep";
        }
    }

    /// <summary>
    /// Add all challenges references to combobox
    /// </summary>
    protected void FillDataDDChallenge()
    {
        var challenges = ChallengeComponent.GetChallenges();

        rdChallengeReference.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdChallengeReference.DataSource = challenges.OrderBy(a => a.ChallengeReference).ToList();
        rdChallengeReference.DataBind();
        rdChallengeReference.Items.Insert(0, new RadComboBoxItem(Localization.GetString("NewChallenge", this.LocalResourceFile), string.Empty));

    }


    /// <summary>
    /// Save the challenge component, the constant attributes are: ChallengeCustomDataId, Reference, Order, Title, Url, TagLine, Content .Depending on the step saves or not the XML.
    /// </summary>
    /// <param name="step"></param>
    /// <param name="challengeReference"></param>
    /// <returns></returns>
    protected bool Save(int step, string challengeReference)
    {
        bool swUrl = false;
        bool sw = true; ;
        challengeComponent = new ChallengeComponent(challengeReference);
        challengeCustomDataComponent = new ChallengeCustomDataComponent(challengeComponent.Challenge.ChallengeReference, rdLanguage.SelectedValue);
        var url = string.Empty;
        if (challengeCustomDataComponent.ChallengeCustomData != null)
        {
            if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Title))
            {
                swUrl = true;
                url = "http://www.nexso.org/" + rdLanguage.SelectedValue.ToLower() + "/c/" + challengeCustomDataComponent.ChallengeCustomData.Title.Replace(" ", "");
            }
        }
        switch (step)
        {
            case 0:
                {

                    if (string.IsNullOrEmpty(challengeComponent.Challenge.ChallengeReference))
                    {
                        challengeComponent = new ChallengeComponent(txtChallengeReference.Text);
                        challengeComponent.Challenge.ChallengeReference = txtChallengeReference.Text;
                        challengeComponent.Challenge.Created = DateTime.Now;
                        challengeComponent.Challenge.Updated = challengeComponent.Challenge.Created;
                        challengeComponent.Challenge.ChallengeTitle = "";

                    }
                    else
                    {
                        challengeComponent = new ChallengeComponent(challengeReference);
                        challengeComponent.Challenge.Updated = DateTime.Now;
                    }

                    if (rdPreLaunch.SelectedDate != null)
                        challengeComponent.Challenge.PreLaunch = Convert.ToDateTime(rdPreLaunch.SelectedDate);
                    else
                        challengeComponent.Challenge.PreLaunch = null;
                    if (rdLaunch.SelectedDate != null)
                        challengeComponent.Challenge.Launch = Convert.ToDateTime(rdLaunch.SelectedDate);
                    else
                        challengeComponent.Challenge.Launch = null;
                    if (rdAvailableFrom.SelectedDate != null)
                        challengeComponent.Challenge.EntryFrom = Convert.ToDateTime(rdAvailableFrom.SelectedDate);
                    else
                        challengeComponent.Challenge.EntryFrom = null;
                    if (rdAvailableTo.SelectedDate != null)
                        challengeComponent.Challenge.EntryTo = Convert.ToDateTime(rdAvailableTo.SelectedDate);
                    else
                        challengeComponent.Challenge.EntryTo = null;
                    if (rdEval1From.SelectedDate != null)
                        challengeComponent.Challenge.ScoringL1From = Convert.ToDateTime(rdEval1From.SelectedDate);
                    else
                        challengeComponent.Challenge.ScoringL1From = null;
                    if (rdEval1To.SelectedDate != null)
                        challengeComponent.Challenge.ScoringL1To = Convert.ToDateTime(rdEval1To.SelectedDate);
                    else
                        challengeComponent.Challenge.ScoringL1To = null;
                    if (rdClosed.SelectedDate != null)
                        challengeComponent.Challenge.Closed = Convert.ToDateTime(rdClosed.SelectedDate);
                    else
                        challengeComponent.Challenge.Closed = null;


                    challengeComponent.Save();

                    FillDataDDChallenge();
                    foreach (RadComboBoxItem item in rdChallengeReference.Items)
                    {
                        if (item.Text.Equals(challengeComponent.Challenge.ChallengeReference))
                        {
                            item.Selected = true;
                        }
                    }
                    rdChallengeReference.SelectedValue = challengeComponent.Challenge.ChallengeReference;
                    rdChallengeReference.Text = challengeComponent.Challenge.ChallengeReference;
                    dvNewChallenge.Visible = false;

                    challengeCustomDataComponent = new ChallengeCustomDataComponent(challengeComponent.Challenge.ChallengeReference, rdLanguage.SelectedValue);

                    if (challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId == Guid.Empty)
                    {
                        challengeCustomDataComponent.ChallengeCustomData.ChallengeReference = challengeComponent.Challenge.ChallengeReference;
                        challengeCustomDataComponent.ChallengeCustomData.Language = rdLanguage.SelectedValue;
                    }
                    challengeCustomDataComponent.ChallengeCustomData.Title = txtChallengeTitle.Text;
                    challengeCustomDataComponent.Save();

                    SetUrlAllPage(challengeCustomDataComponent);
                }
                break;
            case 1:
                {


                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "home");
                    if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                    {
                        challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                        challengePageComponent.ChallengePage.Reference = "home";
                        challengePageComponent.ChallengePage.Order = 0;
                    }


                    challengePageComponent.ChallengePage.Title = txtTitle.Text;

                    if (swUrl)
                        challengePageComponent.ChallengePage.Url = url;

                    challengePageComponent.ChallengePage.Tagline = txtTagLineHome.Text;
                    challengePageComponent.ChallengePage.Description = txtDescriptionHome.Content;




                    if (challengePageComponent.Save() < 0)
                    {
                        sw = false;
                    }

                    challengeComponent.Challenge.Flavor = rdSolutionFlavor.SelectedValue;
                    challengeComponent.Save();



                } break;
            case 2:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "criteria");
                    if (txtTitleCriteria.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {

                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "criteria";
                            challengePageComponent.ChallengePage.Order = 1;
                        }


                        challengePageComponent.ChallengePage.Title = txtTitleCriteria.Text;


                        if (swUrl && txtTitleCriteria.Text != string.Empty)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtCriteriaTagLine.Text;
                        challengePageComponent.ChallengePage.Content = teCriteriaContent.Content;

                        challengePageComponent.ChallengePage.ContentType = "HTML";

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }

                } break;
            case 3:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "judges");
                    if (txtTitleJudges.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {

                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "judges";
                            challengePageComponent.ChallengePage.Order = 2;
                        }


                        challengePageComponent.ChallengePage.Title = txtTitleJudges.Text;


                        if (swUrl)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtJudgesTagLine.Text;

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }

                } break;
            case 4:
                {

                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "partners");

                    if (txtTitlePartners.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {

                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "partners";
                            challengePageComponent.ChallengePage.Order = 3;
                        }


                        challengePageComponent.ChallengePage.Title = txtTitlePartners.Text;


                        if (swUrl)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtPartnersTagLine.Text;


                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }

                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }
                } break;
            case 5:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "faq");
                    if (txtTitleFAQ.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {

                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "faq";
                            challengePageComponent.ChallengePage.Order = 4;
                        }


                        challengePageComponent.ChallengePage.Title = txtTitleFAQ.Text;


                        if (swUrl)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtFAQTagLine.Text;

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }
                } break;
            case 6:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "terms");
                    if (txtTitleTerms.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {

                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "terms";
                            challengePageComponent.ChallengePage.Order = 5;
                        }

                        challengePageComponent.ChallengePage.Title = txtTitleTerms.Text;


                        if (swUrl && txtTitleTerms.Text != string.Empty)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtTermsTagLine.Text;
                        challengePageComponent.ChallengePage.Content = teTermsContent.Content;
                        challengePageComponent.ChallengePage.ContentType = "HTML";

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }
                } break;
            case 7:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "rules");
                    if (txtTitleParticipate.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {
                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "rules";
                            challengePageComponent.ChallengePage.Order = 6;
                        }

                        challengePageComponent.ChallengePage.Title = txtTitleParticipate.Text;

                        if (swUrl && txtTitleParticipate.Text != string.Empty)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtParticipateTagLine.Text;
                        challengePageComponent.ChallengePage.Content = teParticipateContent.Content;
                        challengePageComponent.ChallengePage.ContentType = "HTML";

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }
                } break;
            case 8:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "awards");
                    if (txtTitleAwards.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {
                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "awards";
                            challengePageComponent.ChallengePage.Order = 7;
                        }


                        challengePageComponent.ChallengePage.Title = txtTitleAwards.Text;


                        if (swUrl && txtTitleAwards.Text != string.Empty)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        challengePageComponent.ChallengePage.Tagline = txtAwardsTagLine.Text;
                        challengePageComponent.ChallengePage.Content = teAwardsContent.Content;
                        challengePageComponent.ChallengePage.ContentType = "HTML";

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }
                } break;

            case 9:
                {
                    ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "scoring");
                    if (txtTitleScoring.Text != string.Empty)
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId == Guid.Empty)
                        {
                            challengePageComponent.ChallengePage.ChallengeCustomDataId = challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId;
                            challengePageComponent.ChallengePage.Reference = "scoring";
                            challengePageComponent.ChallengePage.Order = 8;
                        }
                        challengePageComponent.ChallengePage.Title = txtTitleScoring.Text;


                        if (swUrl && txtTitleScoring.Text != string.Empty)
                            challengePageComponent.ChallengePage.Url = url + "/" + challengePageComponent.ChallengePage.Title.Replace(" ", "");
                        else
                            challengePageComponent.ChallengePage.Url = string.Empty;

                        if (challengePageComponent.Save() < 0)
                        {
                            sw = false;
                        }
                    }
                    else
                    {
                        if (challengePageComponent.ChallengePage.ChallengePageId != Guid.Empty)
                        {
                            challengePageComponent.Delete();
                        }

                    }
                } break;
        }

        FillDataPage(challengeComponent.Challenge.ChallengeReference, rdLanguage.SelectedValue);
        return sw;

    }

    /// <summary>
    /// Save All URL of the challenge
    /// </summary>
    /// <param name="challengeCustomDataComponent"></param>
    protected void SetUrlAllPage(ChallengeCustomDataComponent challengeCustomDataComponent)
    {
        bool swUrl = false;
        var url = string.Empty;
        if (challengeCustomDataComponent.ChallengeCustomData != null)
        {
            if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Title))
            {
                swUrl = true;
                url = "http://www.nexso.org/" + rdLanguage.SelectedValue.ToLower() + "/c/" + challengeCustomDataComponent.ChallengeCustomData.Title.Replace(" ", "");
            }
        }

        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "home");
        SaveUrl(challengePageComponent, url, swUrl, true);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "criteria");
        SaveUrl(challengePageComponent, url, swUrl, false);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "judges");
        SaveUrl(challengePageComponent, url, swUrl, false);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "partners");
        SaveUrl(challengePageComponent, url, swUrl, false);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "faq");
        SaveUrl(challengePageComponent, url, swUrl, false);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "terms");
        SaveUrl(challengePageComponent, url, swUrl, false);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "rules");
        SaveUrl(challengePageComponent, url, swUrl, false);
        challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "awards");
        SaveUrl(challengePageComponent, url, swUrl, false);
    }

    /// <summary>
    /// Visible or not visible arrows (up and down) in ítems (criteria, judges, PARTNER, FAQ)
    /// </summary>
    /// <param name="nmPosition"></param>
    /// <param name="page"></param>
    /// <param name="position"></param>
    /// <returns></returns>
    protected bool GetPositionVisible(string nmPosition, string page, string position)
    {
        int ps = Convert.ToInt32(nmPosition);
        List<ListGeneric> list = null;
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        if (page == "JUDGE")
        {
            ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "judges");
            list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);

        }
        if (page == "PARTNER")
        {
            ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "partners");
            list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);

        }
        if (page == "FAQ")
        {
            ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "faq");
            list = GetListFAQ(challengePageComponent.ChallengePage.Content);

        }
        if (page == "ELIGIBILITY")
        {
            list = GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate);
        }

        if (ps == 1 && position == "UP")
            return false;
        else
            if (ps == list.Count() && position == "DOWN")
                return false;
            else
                return true;

    }

    /// <summary>
    /// Display in HTML format (label or texbox) the ítems of diferentlist 
    /// </summary>
    /// <param name="list"></param>
    protected void HTMLControls(List<ListGeneric> list)
    {

        StringBuilder str = new StringBuilder();
        foreach (var item in list)
        {

            switch (item.value1)
            {

                case "Check":
                    str.Append("<input type=\"checkbox\" name=\"" + item.id + "\" value=\"" + item.value2 + "\"> " + item.value2 + "</input></br>");
                    break;
                case "Text":
                    str.Append("<label> " + item.value2 + "</label><input type=\"textbox\" id=\"" + item.id + "\"></input></br>");
                    break;

            }

        }
    }
    protected void BindDataDictionary(List<ListGeneric> list)
    {
        grdDictionary.DataSource = list;
    }
    #endregion

    #region Subclasses
    public class ListGeneric
    {
        public string id { get; set; }
        public string value1 { get; set; }
        public string value2 { get; set; }
        public string value3 { get; set; }
        public string value4 { get; set; }
        public string value5 { get; set; }
        public int position { get; set; }
    }


    #endregion

    #region Events

    protected override void OnLoad(EventArgs e)
    {
        if (!IsPostBack)
        {
            BindData();

            if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - " + DateTime.Now + " - Security Issue"));
                Response.Redirect("/error/403.html");
            }
        }
        var list = ListComponent.GetListPerCategory("TypeControl", Thread.CurrentThread.CurrentCulture.Name).ToList();
        ddTypeControl.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddTypeControl.DataSource = list;
        ddTypeControl.DataBind();




    }
    protected void Page_Load(object sender, EventArgs e)
    {
        wizardChallengeEngine.PreRender += new EventHandler(WizardChallengeEngine_PreRender);
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
    /// Adds to SideBar the steps of the wizard. Additionally adds the controls by step
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WizardChallengeEngine_PreRender(object sender, EventArgs e)
    {
        Repeater SideBarList = wizardChallengeEngine.FindControl("HeaderContainer").FindControl("SideBarList") as Repeater;
        SideBarList.DataSource = wizardChallengeEngine.WizardSteps;
        SideBarList.DataBind();

    }

    /// <summary>
    /// Next button in wizard
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void wizardChallengeEngine_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        string challengeReference = String.Format(rdChallengeReference.Text);

        if (!Save(e.CurrentStepIndex, challengeReference))

            e.Cancel = true;
    }

    /// <summary>
    /// Action of the button finish
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void wizardChallengeEngine_FinishButtonClick(object sender, WizardNavigationEventArgs e)
    {
        string challengeReference = String.Format(rdChallengeReference.Text);

        wizardChallengeEngine.ActiveStepIndex = 0;
    }
    protected void SideBarList_DataBinding(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Load SideBar
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void SideBarList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {


        var link = (LinkButton)e.Item.FindControl("LinkButton1");
        if (link != null)
        {
            var wizardstep = (WizardStep)e.Item.DataItem;
            link.CommandArgument = e.Item.ItemIndex.ToString();
            link.ToolTip = wizardstep.Name;
        }

    }
    protected void Jump_Click(object sender, EventArgs e)
    {
        string challengeReference = String.Format(rdChallengeReference.Text);

        if (challengeReference != Localization.GetString("NewChallenge", this.LocalResourceFile) && !string.IsNullOrEmpty(challengeReference))
        {
            var link = (LinkButton)sender;
            if (Save(wizardChallengeEngine.ActiveStepIndex, challengeReference))
                wizardChallengeEngine.ActiveStepIndex = Convert.ToInt32(link.CommandArgument);
        }
        else
            rfvrdChallengeReference.IsValid = false;
    }

    /// <summary>
    /// Load the challenge selected with the selected language 
    /// </summary>
    /// <param name="o"></param>
    /// <param name="e"></param>
    protected void rdLanguage_SelectedIndexChanged(object o, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        string challengeReference = String.Format(rdChallengeReference.Text);
        challengeFile.Language = rdLanguage.SelectedValue;
        if (challengeReference != Localization.GetString("NewChallenge", this.LocalResourceFile))
        {
            challengeComponent = new ChallengeComponent(challengeReference);
            FillDataPage(challengeReference, rdLanguage.SelectedValue);
        }

    }

    /// <summary>
    /// Add or update a challenge, if any competition is selected load the control dvChallenge else load dvNewChallenge
    /// </summary>
    /// <param name="o"></param>
    /// <param name="e"></param>
    protected void RadComboBox_SelectedIndexChanged(object o, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        string challengeReference = String.Format(rdChallengeReference.Text);
        rdLanguage.SelectedValue = "en-US";
        challengeFile.Language = rdLanguage.SelectedValue;

        if (challengeReference != Localization.GetString("NewChallenge", this.LocalResourceFile))
        {
            dvNewChallenge.Visible = false;
            dvChallenge.Visible = true;
            DataChallenge(challengeReference);
            challengeFile.ChallengeReference = challengeReference;
            challengeFile.BindData();
        }
        else
        {
            dvNewChallenge.Visible = true;
            dvChallenge.Visible = true;
        }
    }
    protected void txtChallengeReference_TextChanged(object sender, EventArgs e)
    {
        var s = revtxtChallengeReference.IsValid;

        var regex = @"^[A-Z0-9a-z]*$";
        var match = Regex.Match(txtChallengeReference.Text, regex, RegexOptions.IgnoreCase);


        if (hfValidateChallenge.Value == "true" && match.Success)
        {

            challengeFile.ChallengeReference = txtChallengeReference.Text;
            challengeFile.BindData();
        }
        else
        {
            if (!match.Success)
                revtxtChallengeReference.IsValid = false;
            if (hfValidateChallenge.Value == "false")
                cvrfvtxtChallengeReference.IsValid = false;

        }
    }
    protected void ibtnEditFAQ_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string faqId = (string)ee.CommandArgument;
        idEditItemFAQ.Value = faqId;

        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "faq");

        var list = GetListFAQ(challengePageComponent.ChallengePage.Content).ToList().FirstOrDefault(x => x.id == faqId);
        txtFAQuestion.Text = list.value1;
        txtFAQAnswer.Content = list.value2;
        txtTagFAQ.Text = list.value3;
        //faqmodal.Visible = true;
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "OpenPopUp(3);", true);

    }
    protected void ibtnDeleteFAQ_Click(object sender, EventArgs e)
    {
        Button ee = (Button)sender;
        string faqId = idEditItemFAQ.Value;
        if (!string.IsNullOrEmpty(faqId))
        {
            ActionsFAQ("DELETE", faqId);
            idEditItemFAQ.Value = string.Empty;
        }
    }
    protected void btnAddFAQ_Click(object sender, EventArgs e)
    {
        string id = idEditItemFAQ.Value;
        if (string.IsNullOrEmpty(id))
        {
            ActionsFAQ("ADD", "");
        }
        else
        {
            ActionsFAQ("EDIT", id);
        }
        //faqmodal.Visible = false;
        idEditItemFAQ.Value = string.Empty;
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "ClosePopUp(3);", true);
    }

    /// <summary>
    /// Customize position of FAQ 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ibtnPositionFAQ_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string FaqId = (string)ee.CommandArgument;
        string position = (string)ee.CommandName;
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "faq");

        var list = GetListFAQ(challengePageComponent.ChallengePage.Content);

        var faqPp = list.FirstOrDefault(x => x.id == FaqId);
        var indexFP = list.FindIndex(x => x.id == FaqId);
        var xml = challengePageComponent.ChallengePage.Content;
        if (position == "DOWN")
        {
            var newPositionFaqPp = faqPp.position + 1;
            var faqSec = list.FirstOrDefault(x => x.position == newPositionFaqPp);
            var indexFS = list.FindIndex(x => x.id == faqSec.id);
            var newPositionFaqSec = faqPp.position;
            list[indexFP].position = newPositionFaqPp;
            list[indexFS].position = newPositionFaqSec;
        }
        else
        {
            var newPositionFaqPp = faqPp.position - 1;
            var faqSec = list.FirstOrDefault(x => x.position == newPositionFaqPp);
            var indexFS = list.FindIndex(x => x.id == faqSec.id);
            var newPositionFaqSec = faqPp.position;
            list[indexFP].position = newPositionFaqPp;
            list[indexFS].position = newPositionFaqSec;
        }
        xml = XML(list.OrderBy(x => x.position).ToList(), "faq");
        challengePageComponent.ChallengePage.Content = xml;
        challengePageComponent.Save();
        FillDataFAQ(GetListFAQ(challengePageComponent.ChallengePage.Content));
    }
    protected void ibtnEditJUDGE_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string JudgeId = (string)ee.CommandArgument;
        idEditItemJudge.Value = JudgeId;
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "judges");

        var list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content).ToList().FirstOrDefault(x => x.id == JudgeId);
        lblPhotoEdit.Visible = true;
        var namePhoto = list.value3.Replace("Portals/0/Judges and Partners/", "");
        lblPhotoEdit.Text = "<i class=\"fa fa-dot-circle-o\" style=\"color:#3786bd\"></i> " + namePhoto;
        txtNameJudge.Text = list.value1;
        txtDescriptionJudge.Content = list.value2;

        txtTagLineJudge.Text = list.value4;
        txtTagJudge.Text = list.value5;
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "OpenPopUp(2);", true);

    }
    protected void ibtnDeleteJUDGE_Click(object sender, EventArgs e)
    {
        Button ee = (Button)sender;
        var JudgeId = idEditItemJudge.Value;
        if (!string.IsNullOrEmpty(JudgeId))
        {
            ActionsJUDGE("DELETE", JudgeId);
            idEditItemJudge.Value = string.Empty;
        }
    }
    protected void btnAddJUDGE_Click(object sender, EventArgs e)
    {
        string id = idEditItemJudge.Value;
        if (string.IsNullOrEmpty(id))
        {
            ActionsJUDGE("ADD", "");
        }
        else
        {
            ActionsJUDGE("EDIT", id);
        }
        //judgemodal.Visible = false;

        idEditItemJudge.Value = string.Empty;

        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "ClosePopUp(2);", true);
    }
    public void RadAsyncUploadPhoto_FileUploaded(object sender, FileUploadedEventArgs e)
    {
        if (RadAsyncUploadPhoto.UploadedFiles.Count > 0)
        {
            string fileName = Path.GetFileNameWithoutExtension(RadAsyncUploadPhoto.UploadedFiles[0].FileName);
            string extensionName = Path.GetExtension(RadAsyncUploadPhoto.UploadedFiles[0].FileName);
            int fileSize = Convert.ToInt32(RadAsyncUploadPhoto.UploadedFiles[0].ContentLength);

            string pathAux = "Portals/0/Judges and Partners/";
            string pathServer = Server.MapPath(pathAux);
            //string pathServer2 = Server.MapPath("Portals/7/TempPhoto/") + fileName + extensionName;
            if (!Directory.Exists(pathServer))
                Directory.CreateDirectory(pathServer);

            try
            {
                string path = pathServer + fileName + extensionName;

                if (!System.IO.File.Exists(path))
                {
                    RadAsyncUploadPhoto.UploadedFiles[0].SaveAs(pathServer + fileName + extensionName);
                }
                else
                {
                    System.IO.File.Delete(path);
                    RadAsyncUploadPhoto.UploadedFiles[0].SaveAs(pathServer + fileName + extensionName);
                }
                hfPhoto.Value = pathAux + fileName + extensionName;

                //if (System.IO.File.Exists(pathServer2))
                //{
                //    System.IO.File.Delete(pathServer2);
                //}

            }
            catch (Exception ex)
            {

            }
            lblPhotoEdit.Visible = true;
            lblPhotoEdit.Text = string.Empty;
        }

    }

    /// <summary>
    /// Customize position of judge 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ibtnPositionJUDGE_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string JudgeId = (string)ee.CommandArgument;
        string position = (string)ee.CommandName;
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "judges");

        var list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);

        var judgePp = list.FirstOrDefault(x => x.id == JudgeId);
        var indexJP = list.FindIndex(x => x.id == JudgeId);
        var xml = challengePageComponent.ChallengePage.Content;
        if (position == "DOWN")
        {
            var newPositionjudgePp = judgePp.position + 1;
            var judgeSec = list.FirstOrDefault(x => x.position == newPositionjudgePp);
            var indexJS = list.FindIndex(x => x.id == judgeSec.id);
            var newPositionjudSec = judgePp.position;
            list[indexJP].position = newPositionjudgePp;
            list[indexJS].position = newPositionjudSec;
        }
        else
        {
            var newPositionjudgePp = judgePp.position - 1;
            var judgeSec = list.FirstOrDefault(x => x.position == newPositionjudgePp);
            var indexJS = list.FindIndex(x => x.id == judgeSec.id);
            var newPositionjudSec = judgePp.position;
            list[indexJP].position = newPositionjudgePp;
            list[indexJS].position = newPositionjudSec;
        }
        xml = XML(list.OrderBy(x => x.position).ToList(), "judge");
        challengePageComponent.ChallengePage.Content = xml;
        challengePageComponent.Save();
        FillDataJUDGE(GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content));
    }
    protected void ibtnEditELIGIBILITY_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string EligId = (string)ee.CommandArgument;
        idEditItemEligibility.Value = EligId;

        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);


        var list = GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate).ToList().FirstOrDefault(x => x.id == EligId);
        ddTypeControl.SelectedValue = list.value1;
        txtEligibility.Text = list.value2;
        //eligibilitymodal.Visible = true;
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "OpenPopUp(1);", true);
        //ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "AddEligibility(1,'" + list.value1 + "','" + list.value2 + "','');", true);

    }
    protected void ibtnDeleteELIGIBILITY_Click(object sender, EventArgs e)
    {
        Button ee = (Button)sender;
        string EligId = idEditItemEligibility.Value;
        if (!string.IsNullOrEmpty(EligId))
        {
            ActionsELIGIBILITY("DELETE", EligId);
            idEditItemEligibility.Value = string.Empty;
        }
    }
    protected void btnAddELIGIBILITY2_Click(object sender, EventArgs e)
    {
        string id = idEditItemEligibility.Value;
        if (string.IsNullOrEmpty(id))
        {
            ActionsELIGIBILITY("ADD", "");
        }
        else
        {
            ActionsELIGIBILITY("EDIT", id);

        }
        //eligibilitymodal.Visible = false;
        idEditItemEligibility.Value = string.Empty;
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "ClosePopUp(1);", true);
    }

    /// <summary>
    /// Customize position of Eligibility criteria 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ibtnPositionELIGIBILITY_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string EligId = (string)ee.CommandArgument;
        string position = (string)ee.CommandName;
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);


        var list = GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate);

        var EligiPp = list.FirstOrDefault(x => x.id == EligId);
        var indexEP = list.FindIndex(x => x.id == EligId);
        var xml = challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate;
        if (position == "DOWN")
        {
            var newPositionEligiPp = EligiPp.position + 1;
            var EligiSec = list.FirstOrDefault(x => x.position == newPositionEligiPp);
            var indexES = list.FindIndex(x => x.id == EligiSec.id);
            var newPositionjudSec = EligiPp.position;
            list[indexEP].position = newPositionEligiPp;
            list[indexES].position = newPositionjudSec;
        }
        else
        {
            var newPositionEligiPp = EligiPp.position - 1;
            var EligiSec = list.FirstOrDefault(x => x.position == newPositionEligiPp);
            var indexES = list.FindIndex(x => x.id == EligiSec.id);
            var newPositionjudSec = EligiPp.position;
            list[indexEP].position = newPositionEligiPp;
            list[indexES].position = newPositionjudSec;
        }
        xml = XML(list.OrderBy(x => x.position).ToList(), "eligibility");
        challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate = xml;
        challengeCustomDataComponent.Save();
        FillDataELIGIBILITY(GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate));
    }
    protected void ibtnEditPARTNER_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string PartnerId = (string)ee.CommandArgument;
        hfPartners.Value = PartnerId;

        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "partners");

        var list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content).ToList().FirstOrDefault(x => x.id == PartnerId);
        lblImageEdit.Visible = true;
        var namePhoto = list.value3.Replace("Portals/0/Judges and Partners/", "");
        lblImageEdit.Text = "<i class=\"fa fa-dot-circle-o\" style=\"color:#3786bd\"></i> " + namePhoto;
        txtNamePartner.Text = list.value1;
        txtDescriptionPartner.Content = list.value2;
        txtTagLinePartner.Text = list.value4;
        txtTagPartner.Text = list.value5;
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "OpenPopUp(4);", true);

    }
    protected void ibtnDeletePARTNER_Click(object sender, EventArgs e)
    {
        Button ee = (Button)sender;
        string PartnerId = hfPartners.Value;
        if (!string.IsNullOrEmpty(PartnerId))
        {
            ActionsPARTNER("DELETE", PartnerId);
            hfPartners.Value = string.Empty;
        }
    }
    protected void btnAddPARTNER_Click(object sender, EventArgs e)
    {
        string id = hfPartners.Value;
        if (string.IsNullOrEmpty(id))
        {
            ActionsPARTNER("ADD", "");
        }
        else
        {
            ActionsPARTNER("EDIT", id);
        }

        hfPartners.Value = string.Empty;

        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "ClosePopUp(4);", true);
    }
    public void RadAsyncUploadImage_FileUploaded(object sender, FileUploadedEventArgs e)
    {
        if (RadAsyncUploadImage.UploadedFiles.Count > 0)
        {
            string fileName = Path.GetFileNameWithoutExtension(RadAsyncUploadImage.UploadedFiles[0].FileName);
            string extensionName = Path.GetExtension(RadAsyncUploadImage.UploadedFiles[0].FileName);
            int fileSize = Convert.ToInt32(RadAsyncUploadImage.UploadedFiles[0].ContentLength);

            string pathAux = "Portals/0/Judges and Partners/";
            string pathServer = Server.MapPath(pathAux);
            if (!Directory.Exists(pathServer))
                Directory.CreateDirectory(pathServer);

            try
            {
                string path = pathServer + fileName + extensionName;

                if (!System.IO.File.Exists(path))
                {
                    RadAsyncUploadImage.UploadedFiles[0].SaveAs(pathServer + fileName + extensionName);
                }
                else
                {
                    System.IO.File.Delete(path);
                    RadAsyncUploadImage.UploadedFiles[0].SaveAs(pathServer + fileName + extensionName);
                }
                hfImage.Value = pathAux + fileName + extensionName;

            }
            catch (Exception ex)
            {

            }
            lblImageEdit.Visible = true;
            lblImageEdit.Text = string.Empty;
        }

    }

    /// <summary>
    /// Customize position of partner 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ibtnPositionPARTNER_Click(object sender, EventArgs e)
    {
        LinkButton ee = (LinkButton)sender;
        string PartnerId = (string)ee.CommandArgument;
        string position = (string)ee.CommandName;
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        ChallengePageComponent challengePageComponent = new ChallengePageComponent(challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId, "partners");

        var list = GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content);

        var partnerPp = list.FirstOrDefault(x => x.id == PartnerId);
        var indexPP = list.FindIndex(x => x.id == PartnerId);
        var xml = challengePageComponent.ChallengePage.Content;
        if (position == "DOWN")
        {
            var newPositionPartnerPp = partnerPp.position + 1;
            var partnerSec = list.FirstOrDefault(x => x.position == newPositionPartnerPp);
            var indexPS = list.FindIndex(x => x.id == partnerSec.id);
            var newPositionPartnerSec = partnerPp.position;
            list[indexPP].position = newPositionPartnerPp;
            list[indexPS].position = newPositionPartnerSec;
        }
        else
        {
            var newPositionPartnerPp = partnerPp.position - 1;
            var partnerSec = list.FirstOrDefault(x => x.position == newPositionPartnerPp);
            var indexPS = list.FindIndex(x => x.id == partnerSec.id);
            var newPositionPartnerSec = partnerPp.position;
            list[indexPP].position = newPositionPartnerPp;
            list[indexPS].position = newPositionPartnerSec;
        }
        xml = XML(list.OrderBy(x => x.position).ToList(), "partners");
        challengePageComponent.ChallengePage.Content = xml;
        challengePageComponent.Save();
        FillDataPARTNER(GetListJUDGEandPARTNER(challengePageComponent.ChallengePage.Content));
    }

    /// <summary>
    /// this button triggers the action to generate the pages in DNN
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnGeneratePages_Click(object sender, EventArgs e)
    {
        string challengeReference = String.Format(rdChallengeReference.Text);
        var valuehf = hfchkPage.Value;
        if (!string.IsNullOrEmpty(valuehf))
        {
            var listSplit = valuehf.Split(';');
            if (listSplit.Count() > 0)
            {
                GetCustomPage(challengeReference, "en-US", listSplit);

                List<string> listLanguage = new List<string>();
                listLanguage.Add("en-US");
                listLanguage.Add("es-ES");
                listLanguage.Add("pt-BR");
                GetCustomPageUrls(challengeReference, "en-US", listSplit, listLanguage);
            }
        }
        ScriptManager.RegisterStartupScript(wizardChallengeEngine, this.GetType(), "script", "alert('Save Pages');", true);
    }
    protected void btnDeletePages_Click(object sender, EventArgs e)
    {
        //if(challengePageComponent.ChallengePage.TabID!=0){

        //}
        //TabInfo oldTab = tabController.GetTab(tabName, portalId);
        //if (oldTab != null)
        //{
        //    if (oldTab.Modules != null)
        //    {
        //        foreach (ModuleInfo mod in oldTab.Modules)
        //        {
        //            ModuleController moduleC = new ModuleController();
        //            moduleC.DeleteModule(mod.ModuleID);
        //            moduleC.DeleteModuleSettings(mod.ModuleID);
        //        }
        //    }

        //    tabController.DeleteTab(oldTab.TabID, portalId);
        //    tabController.DeleteTabSettings(oldTab.TabID);
        //    DataCache.ClearModuleCache(oldTab.TabID);
        //}

    }
    protected void RadGrid1_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);
        if (challengeCustomDataComponent != null)
        {
            BindDataDictionary(GetListDictionary(challengeCustomDataComponent.ChallengeCustomData.Tags));
        }
    }

    /// <summary>
    /// Order recent solutions
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    protected void grdRecentSolution_SortCommand(object source, GridSortCommandEventArgs e)
    {
        string orderByFormat = string.Empty;
        switch (e.NewSortOrder)
        {
            case GridSortOrder.Ascending:
                orderByFormat = "ORDER BY {0} ASC";
                break;
            case GridSortOrder.Descending:
                orderByFormat = "ORDER BY {0} DESC";
                break;
        }
        e.Item.OwnerTableView.Rebind();
    }
    protected void RadGrid1_DeleteCommand(object source, Telerik.Web.UI.GridCommandEventArgs e)
    {
        string ID = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["id"].ToString();
        challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);

        var list = GetListDictionary(challengeCustomDataComponent.ChallengeCustomData.Tags);
        var listDic = list;
        listDic = list.Where(a => a.id != ID).ToList();
        var xmlstring = XML(listDic.ToList(), "dictionary");


        if (challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId != Guid.Empty)
        {
            challengeCustomDataComponent.ChallengeCustomData.Tags = xmlstring;
            challengeCustomDataComponent.Save();
        }
        this.grdDictionary.MasterTableView.Rebind();
    }
    protected void RadGrid1_UpdateCommand(object sender, GridCommandEventArgs e)
    {
        if (e.CommandName == RadGrid.UpdateCommandName)
        {
            if (e.Item is GridEditableItem)
            {
                GridEditableItem editItem = (GridEditableItem)e.Item;
                TextBox txtKey = (TextBox)editItem.FindControl("txtKey");
                TextBox txtValue = (TextBox)editItem.FindControl("txtValue");
                TextBox txtId = (TextBox)editItem.FindControl("txtId");

                var id = txtId.Text;

                challengeCustomDataComponent = new ChallengeCustomDataComponent(rdChallengeReference.SelectedValue, rdLanguage.SelectedValue);

                var list = GetListDictionary(challengeCustomDataComponent.ChallengeCustomData.Tags);
                var listDic = list;
                ListGeneric dicEdit = null;
                var dicEditaux = list.Where(a => a.id != id && a.value1 == txtKey.Text);
                if (dicEditaux.Count() > 0)
                {
                    cvtxtKey.IsValid = false;

                    return;
                }
                else
                {
                    cvtxtKey.IsValid = true;
                }

                if (editItem.ItemIndex != -1)
                {
                    dicEdit = list.FirstOrDefault(a => a.id == id);
                    listDic = list.Where(a => a.id != id).ToList();
                }

                var ID = Guid.NewGuid().ToString();

                if (editItem.ItemIndex != -1)
                {
                    ID = dicEdit.id;
                }
                listDic.Add(new ListGeneric { id = ID, value1 = txtKey.Text, value2 = txtValue.Text });


                var xmlstring = XML(listDic.ToList(), "dictionary");


                if (challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId != Guid.Empty)
                {
                    challengeCustomDataComponent.ChallengeCustomData.Tags = xmlstring;
                    challengeCustomDataComponent.Save();
                }

                if (editItem.ItemIndex != -1)
                    this.grdDictionary.MasterTableView.Items[editItem.ItemIndex].Edit = false;
                else
                    e.Item.OwnerTableView.IsItemInserted = false;


                BindDataDictionary(GetListDictionary(challengeCustomDataComponent.ChallengeCustomData.Tags));
            }
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

