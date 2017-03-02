using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class SolutionListComponent
    {
        private SolutionList solutionList;
        private MIFNEXSOEntities mifnexsoEntities;

        public SolutionList SolutionList
        {
            get { return solutionList; }
        }






        public SolutionListComponent(Guid solutionId, string key, string category)
        {


            if (!string.IsNullOrEmpty(key))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    solutionList = mifnexsoEntities.SolutionLists.FirstOrDefault(a => a.SolutionId == solutionId && a.Key == key && a.Category == category);


                    if (solutionList == null)
                    {
                        solutionList = new SolutionList();
                        solutionList.ListId = Guid.NewGuid();
                        solutionList.Key = key;
                        solutionList.SolutionId = solutionId;
                        solutionList.Category = category;

                        mifnexsoEntities.SolutionLists.AddObject(solutionList);
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
                mifnexsoEntities.DeleteObject(solutionList);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = solutionList.EntityState;
            if (solutionList.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(solutionList);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.SolutionLists.AddObject(solutionList);
                else
                    mifnexsoEntities.SolutionLists.Attach(solutionList);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<SolutionList> GetListPerCategory(Guid solutionId, string category)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionLists

                         where c.SolutionId == solutionId && c.Category == category
                         select c;

            return result;



        }

        public static IQueryable<SolutionList> GetListPerCategory(string category, string key)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionLists

                         where c.Category == category && c.Key == key
                         select c;

            return result;



        }

        public static bool deleteListPerCategory(Guid solutionId, string category)
        {
            try
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                int results = mifnexsoEntities.ExecuteStoreCommand(
                     string.Format("DELETE SOLUTIONLISTS WHERE SolutionId='{0}' and Category='{1}'", solutionId.ToString(),
                                   category));
                return true;
            }
            catch (Exception)
            {
                return false;
            }




        }


    }


}
