using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;

namespace NexsoProBLL
{

    public class MailFilter
    {
        public  string Table;
        public string Field;
        public string DataType;
        public List<string> FilterValue;
        public string Operator;
        public string ConcatenateOperator;
        public string Command;

    }


    public class MailContainer
    {
        public List< MailFilter> MailFilter;
        public List<AdditionalRecipient> AdditionalRecipients;
        public List<UserProperty> UserProperty;
        public List<Guid> ExceptionsExclude;
        public List<Guid> ExceptionsInclude;


        public MailContainer()
        {
            MailFilter=new List<MailFilter>();
            AdditionalRecipients = new List<AdditionalRecipient>();
        }
    }




    public class AdditionalRecipient
    {
        public string name;
        public string email;
    }

  
}
