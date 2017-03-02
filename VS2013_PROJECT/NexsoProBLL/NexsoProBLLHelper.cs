using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;

namespace NexsoProBLL
{
    class NexsoProBLLHelper
    {
    }

    public class OrganizationSolution
    {
        public Organization Organization { get; set; }
        public Solution Solution { get; set; }
    }

    public class UserPropertyOrganizationSolution
    {
        public Organization Organization { get; set; }
        public Solution Solution { get; set; }
        public UserProperty UserProperty { get; set; }
    }
}
