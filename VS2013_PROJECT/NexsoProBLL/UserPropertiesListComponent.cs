using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class UserPropertiesListComponent
    {
        private UserPropertiesList userPropertiesList;
        private MIFNEXSOEntities mifnexsoEntities;

        public UserPropertiesList UserPropertiesList
        {
            get { return userPropertiesList; }
        }






        public UserPropertiesListComponent(int userId, string key, string category)
        {


            if (!string.IsNullOrEmpty(key))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    userPropertiesList = mifnexsoEntities.UserPropertiesLists.FirstOrDefault(a => a.UserPropertyId == userId && a.Key == key && a.Category == category);


                    if (userPropertiesList == null)
                    {
                        userPropertiesList = new UserPropertiesList();
                        userPropertiesList.ListId = Guid.NewGuid();
                        userPropertiesList.Key = key;
                        userPropertiesList.UserPropertyId = userId;
                        userPropertiesList.Category = category;

                        mifnexsoEntities.UserPropertiesLists.AddObject(userPropertiesList);
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
            catch (Exception e)
            {

                return -1;
            }


        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(userPropertiesList);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = userPropertiesList.EntityState;
            if (userPropertiesList.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(userPropertiesList);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.UserPropertiesLists.AddObject(userPropertiesList);
                else
                    mifnexsoEntities.UserPropertiesLists.Attach(userPropertiesList);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<UserPropertiesList> GetListPerCategory(int userId, string category)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.UserPropertiesLists

                         where c.UserPropertyId == userId && c.Category == category
                         select c;

            return result;



        }

        public static IQueryable<UserPropertiesList> GetListPerCategory(string category, string key)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.UserPropertiesLists

                         where c.Category == category && c.Key == key
                         select c;

            return result;



        }

        public static bool deleteListPerCategory(int userId, string category)
        {
            try
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                int results = mifnexsoEntities.ExecuteStoreCommand(
                     string.Format("DELETE UserPropertiesLists WHERE UserPropertyId={0} and Category='{1}'", userId.ToString(),
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
