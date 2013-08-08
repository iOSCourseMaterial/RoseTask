""" Model classes for the RoseTask API """

from google.appengine.ext import endpoints
from google.appengine.ext import ndb
from endpoints_proto_datastore.ndb import EndpointsModel

import logging

class Task(EndpointsModel):
    """ Model to store a single task"""
    text = ndb.StringProperty(required=True)
    task_list_id = ndb.IntegerProperty(required=True)
    complete = ndb.BooleanProperty(default=False)
    assigned_to_email = ndb.StringProperty(required=False)
    created = ndb.DateTimeProperty(auto_now=True)
    creator = ndb.UserProperty(required=False)
    
class TaskList(EndpointsModel):
    """ Model to store a lists of task and list of users"""
    title = ndb.StringProperty(required=True)
    task_keys = ndb.KeyProperty(kind=Task,repeated=True)
    task_user_emails = ndb.StringProperty(repeated=True)
    created = ndb.DateTimeProperty(auto_now_add=True)
    creator = ndb.UserProperty(required=False)
    
    @classmethod
    def flush_task_users(cls, a_task_list_id, emails_that_will_be_connected):
        # Remove the TaskUser reference to the TaskList
        datastore_task_list = ndb.Key(cls, a_task_list_id).get()
        for an_email in datastore_task_list.task_user_emails:
            if an_email in emails_that_will_be_connected:
                logging.info("Not bothering to remove " + str(datastore_task_list.key.id()) + " from " + str(an_email))
                continue
            logging.info("Removing " + str(datastore_task_list.key.id()) + " from " + str(an_email))
            a_task_user = TaskUser.get_task_user_by_email(an_email)
            if datastore_task_list.key in a_task_user.task_list_keys:
                logging.info("Found that TaskList key in the TaskUser key list as expected.")
            else:
                logging.info("Did NOT find the key " + str(datastore_task_list.key))
            a_task_user.task_list_ids.remove(datastore_task_list.key)
            a_task_user.put()
        
class TaskUser(EndpointsModel):
    """ Model that represents an individual user. """
    lowercase_email = ndb.StringProperty(required=True) # Also using lowercase_email as the entity key name
    preferred_name = ndb.StringProperty(required=False)
    google_plus_id = ndb.StringProperty(required=False)
    task_list_keys = ndb.KeyProperty(kind=TaskList,repeated=True)
    created = ndb.DateTimeProperty(auto_now=True)
    # Consider adding a blob property for the image.

    @classmethod
    def get_task_user_by_email(cls, an_email):
        """ Get or create a TaskUser (always use this method). """
        an_email = an_email.lower() # Just in case.
        a_task_user_key = ndb.Key(cls, an_email)
        a_task_user = a_task_user_key.get()
        if a_task_user:
            return a_task_user
        else:
            new_task_user = TaskUser(id = an_email, lowercase_email = an_email)
            return new_task_user

    @classmethod
    def add_task_list(cls, task_list_key, an_email):
        """ Adds a TaskList key to the TaskUser if not already present. """
        a_task_user = cls.get_task_user_by_email(an_email)
        if not task_list_key in a_task_user.task_list_keys:
            a_task_user.task_list_keys.append(task_list_key)
            a_task_user.put()