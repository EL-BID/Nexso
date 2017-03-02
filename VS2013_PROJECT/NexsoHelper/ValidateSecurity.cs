using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;


public class ValidateSecurity
{

    public ValidateSecurity()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static string ValidateString(string text, bool isHtml)
    {
        string _returnText = string.Empty;

        if (!isHtml)
        {
            Regex regJs = new Regex(@"(<script(\s|\S)*?<\/script>)|(<style(\s|\S)*?<\/style>)|(<!--(\s|\S)*?-->)|(<\/?(\s|\S)*?>)");
            bool sw = regJs.IsMatch(text);
            if (!sw)
                _returnText = text;
            else
                throw new Exception("Security Issue");
        }

        return WebUtility.HtmlEncode(_returnText);
    }




}

