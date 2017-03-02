using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;

namespace NexsoProBLL
{
    public class UserNotificationConnectionComponent
    {
        private UserNotificationConnection userNotificationConnection;
        private MIFNEXSOEntities mifnexsoEntities;

        public UserNotificationConnection UserNotificationConnection
        {
            get { return userNotificationConnection; }
        }



        public UserNotificationConnectionComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            userNotificationConnection = new UserNotificationConnection();
            userNotificationConnection.UserNotificationConnection1 = Guid.Empty;
            userNotificationConnection.NotificationId = Guid.Empty;
            mifnexsoEntities.UserNotificationConnections.AddObject(userNotificationConnection);
        }

        public UserNotificationConnectionComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    userNotificationConnection = mifnexsoEntities.UserNotificationConnections.FirstOrDefault(a => a.UserNotificationConnection1 == guid);
                }
                else
                {
                    userNotificationConnection = new UserNotificationConnection();
                    userNotificationConnection.UserNotificationConnection1 = Guid.Empty;
                    userNotificationConnection.NotificationId = Guid.Empty;
                    mifnexsoEntities.UserNotificationConnections.AddObject(userNotificationConnection);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        public int Save()
        {
            try
            {
                if (userNotificationConnection.UserNotificationConnection1 == Guid.Empty)
                    userNotificationConnection.UserNotificationConnection1 = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(userNotificationConnection);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = userNotificationConnection.EntityState;
            if (userNotificationConnection.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(userNotificationConnection);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.UserNotificationConnections.AddObject(userNotificationConnection);
                else
                    mifnexsoEntities.UserNotificationConnections.Attach(userNotificationConnection);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        #region Static Methods
        public static IQueryable<UserNotificationConnection> GetUserNotificationConnections(Guid NotificationId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.UserNotificationConnections
                         where c.NotificationId == NotificationId
                         select c;

            return result;

        }
        public static IQueryable<UserNotificationConnection> GetUserNotificationConnections(int UserId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.UserNotificationConnections
                         where c.UserId == UserId
                         select c;

            return result;

        }
        #endregion
    }

}
