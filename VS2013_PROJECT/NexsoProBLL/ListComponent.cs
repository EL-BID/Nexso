using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class ListComponent
    {
        private List list;
        private MIFNEXSOEntities mifnexsoEntities;

        public List ListItem
        {
            get { return list; }
        }






        public ListComponent(string key, string category)
        {


            if (!string.IsNullOrEmpty(key))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    list = mifnexsoEntities.Lists.FirstOrDefault(a => a.Key == key && a.Category == category);


                    if (list == null)
                    {
                        list = new List();
                        list.Key = key;
                        list.Value = string.Empty;
                        list.Category = string.Empty;

                        mifnexsoEntities.Lists.AddObject(list);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }

        public ListComponent(string key, string category, string culture)
        {


            if (!string.IsNullOrEmpty(key))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    list = mifnexsoEntities.Lists.FirstOrDefault(a => a.Key == key && a.Category == category && a.Culture==culture);


                    if (list == null)
                    {
                        list = new List();
                        list.Key = key;
                        list.Value = string.Empty;
                        list.Category = string.Empty;

                        mifnexsoEntities.Lists.AddObject(list);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }

        public int Save()
        {
            try
            {
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }


        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(list);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = list.EntityState;
            if (list.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(list);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Lists.AddObject(list);
                else
                    mifnexsoEntities.Lists.Attach(list);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<List> GetListPerCategory(string category, string culture)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Lists

                         where c.Category == category && c.Culture == culture
                         orderby c.Order
                         select c;




            return result;



        }

        public static string GetLabelFromListValue(string category, string culture, string value)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Lists
                         where c.Category == category && c.Culture == culture && c.Value == value
                         select c;

            var return_ = result.FirstOrDefault();
            if (return_ != null)
            {
                return return_.Label;
            }
            else
            {
                return string.Empty;
            }


        }

        public static string GetLabelFromListKey(string category, string culture, string key)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Lists
                         where c.Category == category && c.Culture == culture && c.Key == key
                         select c;

            var return_ = result.FirstOrDefault();
            if (return_ != null)
            {
                return return_.Label;
            }
            else
            {
                return string.Empty;
            }


        }
    }


}
