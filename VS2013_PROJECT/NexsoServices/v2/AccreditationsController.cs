using DotNetNuke.Web.Api;
using NexsoProBLL;
using NexsoServices.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;

namespace NexsoServices.v2
{
    /// <summary>
    /// Controller for general Lists
    /// </summary>
    public class AccreditationController : DnnApiController
    {

        [AllowAnonymous]
        [HttpGet]
        //get all accreditations list
        public List<AccreditationsModel> GetList(int? userId = null, int rows = 10, int page = 0, int min = 0, int max = 0, int state = 1000, string language = "en-US")
        {

            try
            {
                List<AccreditationsModel> ListAccreditation = new List<AccreditationsModel>();

                var result = AccreditationsComponent.GetAccreditationList().ToList().OrderBy(x => x.OrganizationId);

                var totalCount = result.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                var prevLink = page > 0 ? string.Format("/Accreditations/GetList?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/Accreditations/GetList?rows={0}&page={1}", rows, page + 1) : "";


                foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                {
                    ListAccreditation.Add(new AccreditationsModel()
                    {
                        AccreditationId = (Guid)resultTmp.AccreditationId,
                        OrganizationId = (Guid)resultTmp.OrganizationId,
                        Content = resultTmp.Content,
                        Description = resultTmp.Description,
                        DocumentId = (Guid)resultTmp.DocumentId,
                        Name = resultTmp.Name,
                        Type = resultTmp.Type
                    });
                }
                return ListAccreditation;
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


        [AllowAnonymous]
        [HttpGet]
        //get all references by organization
        public List<AccreditationsModel> GetAccreditation(Guid organization, int? userId = null, int rows = 10, int page = 0, int min = 0, int max = 0, int state = 1000, string language = "en-US")
        {

            try
            {
                List<AccreditationsModel> ListAccreditation = new List<AccreditationsModel>();

                var result = AccreditationsComponent.GetAccreditationId(organization).ToList().OrderBy(x => x.OrganizationId);

                var totalCount = result.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                var prevLink = page > 0 ? string.Format("/Accreditations/GetAccreditation?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/Accreditations/GetAccreditation?rows={0}&page={1}", rows, page + 1) : "";


                foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                {
                    ListAccreditation.Add(new AccreditationsModel()
                    {
                        AccreditationId = (Guid)resultTmp.AccreditationId,
                        OrganizationId = (Guid)resultTmp.OrganizationId,
                        Content = resultTmp.Content,
                        Description = resultTmp.Description,
                        DocumentId = (Guid)resultTmp.DocumentId,
                        Name = resultTmp.Name,
                        Type = resultTmp.Type
                    });
                }
                return ListAccreditation;
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
