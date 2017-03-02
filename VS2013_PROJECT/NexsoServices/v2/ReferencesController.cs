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
    public class ReferencesController : DnnApiController
    {

        [AllowAnonymous]
        [HttpGet]
        //get all references list
        public List<ReferencesModel> GetList(int? userId = null, int rows = 10, int page = 0, int min = 0, int max = 0, int state = 1000, string language = "en-US")
        {
            try
            {
                List<ReferencesModel> ListReferences = new List<ReferencesModel>();

                var result = ReferencesComponent.GetList().ToList().OrderBy(x => x.OrganizationId);

                var totalCount = result.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                var prevLink = page > 0 ? string.Format("/References/GetList?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/References/GetList?rows={0}&page={1}", rows, page + 1) : "";

                foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                {
                    ListReferences.Add(new ReferencesModel()
                    {


                        ReferenceId = (Guid)resultTmp.ReferenceId,
                        OrganizationId = (Guid)resultTmp.OrganizationId,
                        UserId = resultTmp.UserId, 
                        Type =  resultTmp.Type,
                        Comment = resultTmp.Comment,
                        Created = resultTmp.Created.ToString(),
                        Updated = resultTmp.Updated.ToString(),
                        Deleted = resultTmp.Deleted

                    });
                }
                return ListReferences;
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
        public List<ReferencesModel> GetReference(Guid organization, int? userId = null, int rows = 10, int page = 0, int min = 0, int max = 0, int state = 1000, string language = "en-US")
        {
            try
            {
                List<ReferencesModel> ListReferences = new List<ReferencesModel>();

                var result = ReferencesComponent.GetReferences(organization).ToList();

                var totalCount = result.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                var prevLink = page > 0 ? string.Format("/References/GetReference?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/References/GetReference?rows={0}&page={1}", rows, page + 1) : "";

                foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                {
                    ListReferences.Add(new ReferencesModel()
                    {


                        ReferenceId = (Guid)resultTmp.ReferenceId,
                        OrganizationId = (Guid)resultTmp.OrganizationId,
                        UserId = resultTmp.UserId,
                        Type = resultTmp.Type,
                        Comment = resultTmp.Comment,
                        Created = resultTmp.Created.ToString(),
                        Updated = resultTmp.Updated.ToString(),
                        Deleted = resultTmp.Deleted

                    });
                }
                return ListReferences;
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
