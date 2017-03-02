#region [Using]
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using System.Text.RegularExpressions;
using NexsoProBLL;
using DotNetNuke.Web.Api;
using Newtonsoft.Json;

#endregion

namespace NexsoServices.v2
{
    /// <summary>
    /// 
    /// </summary>
    public class StatisticsController : DnnApiController
    {
        /// <summary>
        /// Get statistics of members, solutions and startups
        /// </summary>
        [AllowAnonymous]
        [HttpGet]
        public string GetStatistics(string ChallengeReferences = "")
        {
            List<string>  challengeReferences = new List<string>();
            if (!string.IsNullOrEmpty(ChallengeReferences))
            {
                string references = Regex.Replace(ChallengeReferences, @"\s+", "");
                references = !string.IsNullOrEmpty(references) ? references : "";
                if (references.Contains(","))
                {
                    challengeReferences = references.Split(',').ToList();
                }
                else
                {
                    challengeReferences.Add(references);
                }
            }
            else
            {
                challengeReferences.Add("");
            }

            Dictionary<string, string> result = new Dictionary<string, string>();
            var users = UserPropertyComponent.GetUsersStatistics();
            var totalUsers = users.Count();
            var getSolutionStatistics = SolutionComponent.GetSolutionStatistics();
            var totalSolutions = getSolutionStatistics.Count();
            var startupsSolutions = getSolutionStatistics.Where(x => x.ChallengeReference == "DEMAND_SOLUTIONS2015" || x.ChallengeReference == "EconomiaNaranja").Count();
            result.Add("Users", totalUsers.ToString());
            result.Add("Solutions", totalSolutions.ToString());
            result.Add("Startups", startupsSolutions.ToString());
            return JsonConvert.SerializeObject(result);
        }
    }
}

