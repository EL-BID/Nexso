using NexsoProDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace NexsoProBLL
{
   public class NotificationComponent
    {
       private Notification notification;
        private MIFNEXSOEntities mifnexsoEntities;

        public Notification Notification
        {
            get { return notification; }
        }



        public NotificationComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            notification = new Notification();
            notification.NotificationId = Guid.Empty;
            mifnexsoEntities.Notifications.AddObject(notification);
        }

        public NotificationComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    notification = mifnexsoEntities.Notifications.FirstOrDefault(a => a.NotificationId == guid);
                }
                else
                {
                    notification = new Notification();
                    notification.NotificationId = Guid.Empty;
                    mifnexsoEntities.Notifications.AddObject(notification);
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
                if (notification.NotificationId == Guid.Empty)
                    notification.NotificationId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(notification);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = notification.EntityState;
            if (notification.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(notification);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Notifications.AddObject(notification);
                else
                    mifnexsoEntities.Notifications.Attach(notification);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region Static Methods
        public static IQueryable<Notification> GetNotifications(int UserId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Notifications
                         where c.UserId == UserId
                         select c;

            return result;

        }
        #endregion
    }
}
