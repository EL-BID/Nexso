using System;
using System.Data.Common;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using DotNetNuke.Web.Api;
using System.Text;
using System.Web;
using Newtonsoft.Json;
using System.Linq;
using Newtonsoft;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Users;
using DotNetNuke.Security.Roles;
using System.Collections.Generic;
using System.Globalization;
using NexsoProBLL;
using NexsoProDAL;
using System.Data.Objects;
using System.IO;
using System.Threading;

using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Web.Http.Controllers;
using System.Web.Http.Filters;
using ImageProcessor;
using System.Drawing;
using System.Resources;
using System.Reflection;
using System.Collections;
using NexsoServices.Helper;
using NexsoServices.V2;

namespace NexsoServices.v2
{
    /// <summary>
    /// Challenge controller
    /// </summary>
    public class ChallengesController : DnnApiController
    {

        /// <summary>
        /// Get comment list
        /// </summary>
        /// <remarks>
        /// Get a list of challenges.
        /// 
        /// Pagination information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference
        /// </remarks>
        /// 
        /// <param name="language">Default en-US</param>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpGet]
        public List<ChallengeModel> GetList(string language = "en-US", int rows = 10, int page = 0, string brand = "")
        {
            try
            {
                IOrderedQueryable<ChallengeSchema> result = null;
                if (string.IsNullOrEmpty(brand))
                    result = ChallengeComponent.GetChallengesFront().OrderByDescending(x => x.EntryTo);
                else
                    result = ChallengeComponent.GetChallengesFront(brand).OrderByDescending(x => x.EntryTo);

                var totalCount = result.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);


                var prevLink = page > 0 ? string.Format("/Challenges/GetList?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/Challenges/GetList?rows={0}&page={1}", rows, page + 1) : "";
                List<ChallengeModel> ChallengeModel = new List<ChallengeModel>();

                foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                {
                    var challengeCustomDataComponent = new ChallengeCustomDataComponent(resultTmp.ChallengeReference, language);


                    var isOpen = true;


                    if (!string.IsNullOrEmpty(resultTmp.EntryFrom.ToString()) && !string.IsNullOrEmpty(resultTmp.EntryTo.ToString()))
                    {
                        if (!(Convert.ToDateTime(resultTmp.EntryFrom) < DateTime.Now && Convert.ToDateTime(resultTmp.EntryTo) > DateTime.Now))
                            isOpen = false;

                    }


                    var Open = Convert.ToDateTime(resultTmp.EntryFrom.GetValueOrDefault());
                    var Close = Convert.ToDateTime(resultTmp.EntryTo.GetValueOrDefault());
                    string dateValueOpen = Open.ToString("MMM dd, yyyy", new CultureInfo(language, false));
                    string dateValueClose = Close.ToString("MMM dd, yyyy", new CultureInfo(language, false));




                    ChallengeModel.Add(new ChallengeModel()
                    {
                        ChallengeReference = resultTmp.ChallengeReference,
                        Title = challengeCustomDataComponent.ChallengeCustomData.Title,
                        Description = challengeCustomDataComponent.ChallengeCustomData.Description,
                        Open = dateValueOpen,
                        Close = dateValueClose,
                        IfOpen = isOpen,
                        UrlBanner = challengeCustomDataComponent.ChallengeCustomData.BannerFront,
                        UrlChallenge = challengeCustomDataComponent.ChallengeCustomData.UrlChallengeFront
                    });

                }

                var paginationHeader = new
                {
                    TotalCount = totalCount,
                    TotalPages = totalPages,
                    PrevPageLink = prevLink,
                    NextPageLink = nextLink
                };

                System.Web.HttpContext.Current.Response.Headers.Add("X-Pagination",
                Newtonsoft.Json.JsonConvert.SerializeObject(paginationHeader));

                return ChallengeModel;

            }
            catch (HttpResponseException e)
            {
                throw e;
            }
            catch (Exception ee)
            {
                DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
            }

        }
    
    
    }
}
