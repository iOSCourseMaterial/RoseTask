#!/usr/bin/python



"""TaskMaster API implemented using Google Cloud Endpoints."""

from google.appengine.ext import endpoints
from protorpc import remote

from old_models import TaskUser
from old_models import Task
from old_models import TaskList

import logging

# For https://rose-task.appspot.com
CLIENT_ID = '692785471170.apps.googleusercontent.com';

# For http://localhost:8080
CLIENT_ID_LOCALHOST = '692785471170-eb3d0s8l8mats4knvint6i35977uoojv.apps.googleusercontent.com'

# For my iOS client.  
CLIENT_ID_IOS = '692785471170-iphols9ldsfi4596dn12oc617400d7qc.apps.googleusercontent.com';

@endpoints.api(name='rosetask', version='v1',
               description='Rose Task API',
               allowed_client_ids=[CLIENT_ID, CLIENT_ID_LOCALHOST, CLIENT_ID_IOS, endpoints.API_EXPLORER_CLIENT_ID])
class RoseTaskApi(remote.Service):
    """Class which defines rosetask API v1."""

    @TaskUser.method(user_required=True, path='taskuser', http_method='POST', name='taskuser.insert')
    def TaskUserInsert(self, a_task_user):
        """ Create with preferred and update the Google Plus ID. """
        # Assume I'll get the Google+ id on the client side when a user logs in.
        request_email = a_task_user.lowercase_email.lower()
        current_user_email = endpoints.get_current_user().email().lower()
        if current_user_email != request_email:
            logging.info('Current user email = ' + current_user_email + '  TaskUser email = ' + request_email)            
            #Allow odd creations for testing.  Turn off later as you should only edit yourself.
            #raise endpoints.ForbiddenException("Only can only edit/create your own TaskUser.")
        the_task_user = TaskUser.get_task_user_by_email(request_email)
        the_task_user.preferred_name = a_task_user.preferred_name
        the_task_user.google_plus_id = a_task_user.google_plus_id
        the_task_user.put()
        return the_task_user
    
    @TaskUser.method(user_required=True, request_fields=('id',), path='taskuser/{id}', http_method='GET', name='taskuser.get')
    def TaskUserGet(self, a_task_user):
        """ Simple get to return one TaskUser from the one email given. """
        if not a_task_user.from_datastore:
            raise endpoints.NotFoundException("TaskUser not found.")
        return a_task_user

    @TaskUser.query_method(user_required=True, query_fields=('lowercase_email',), path='taskuser', http_method='GET', name='taskuser.gettaskuser')
    def TaskUserGetTaskUser(self, query):
        """ Returns the TaskUser for the email given """
        return query
    
    # Not valid "No queries on repeated values are allowed."
#     @TaskUser.query_method(user_required=True, query_fields=('task_list_ids', 'pageToken',), path='taskuser', name='taskuser.gettaskusers')
#     def TaskUserGetTaskUsers(self, query):
#         """ Returns all the TaskUsers in the TaskList """
#         # This feels poorly done.  It's not using the list of Keys in the TaskList just the reverse conneciton. :(
#         return query

    @Task.method(user_required=True, path='task', http_method='POST', name='task.insert')
    def TaskInsert(self, a_task):
        """ Insert a Task into the TaskList (used for edits and new Tasks) """
        a_task.creator = endpoints.get_current_user()
        parent_task_list = TaskList.get_by_id(a_task.task_list_id)
        a_task.anestor = parent_task_list
        if a_task.assigned_to_email:
            if a_task.assigned_to_email.lower() in parent_task_list.task_users_emails:
                a_task.assigned_to_email = a_task.assigned_to_email.lower()
                a_task.assigned_to = TaskUser.get_task_user_by_email(a_task.assigned_to_email).key
            else:
                logging.info("Attempt to assign user that is not in the TaskList.")
                a_task.assigned_to_email = None
        a_task.put()
        # Make sure the Task is in the TaskList's tasks
        parent_task_list.tasks.append(a_task.key)
        parent_task_list.put()
        return a_task
    
    @Task.query_method(user_required=True, query_fields=('task_list_id', 'order', 'pageToken',), path='tasks', name='task.gettasks')
    def TaskGetTasks(self, query):
        """ Returns the Tasks that share the task_list_id (ie Tasks that are in the TaskList)"""
        # This feels poorly done.  It's not using the parent nature, NOR the list of Keys in the TaskList. :(
        return query

    @Task.method(user_required=True, request_fields=('id',), path='task/{id}', http_method='GET', name='task.delete')
    def TaskDelete(self, a_task):
        """ Delete a Task. """
        if not a_task.from_datastore:
            raise endpoints.NotFoundException("Task not found.")
        # Remove the key from the TaskList
        parent_task_list = TaskList.get_by_id(a_task.task_list_id)
        parent_task_list.tasks.remove(a_task.key)
        parent_task_list.put()
        a_task.key.delete()
        return Task(text="deleted")
        
    @TaskList.method(user_required=True, path='tasklist', http_method='POST', name='tasklist.insert')
    def TaskListInsert(self, a_task_list):
        """ Creates a new TaskList (also used to edit an existing TaskList). """
        a_task_list.creator = endpoints.get_current_user()
        if a_task_list.from_datastore:
            logging.info("This is an update not a new TaskList")
            a_task_list.flush_task_users_list()
        else:
            a_task_list.put() # Generate an id because it'll be needed for next steps.
        # Add the current user as a TaskUser in the key list
        emails = [endpoints.get_current_user().email().lower()]
        a_task_list.add_task_user_by_email(endpoints.get_current_user().email().lower())        
        # Now go through all the emails and add them too.
        for an_email in a_task_list.task_users_emails:
            #logging.info("Adding " + an_email.lower() + " to the TaskList")
            a_task_list.add_task_user_by_email(an_email.lower())
            emails.append(an_email.lower())
        a_task_list.task_users_emails = emails
        a_task_list.put() # Second put now that the task_users are in.
        return a_task_list
    
    @TaskList.query_method(user_required=True, query_fields=('order', 'pageToken'), path='tasklist', name='tasklist.gettasklists')
    def TaskListGetTaskLists(self, query):
        """ Returns all the TaskLists for the logged in user. """
        my_task_user = TaskUser.get_task_user_by_email(endpoints.get_current_user().email().lower())
        query.filter(id.IN(my_task_user.task_list_ids))
        return query

    @TaskList.method(user_required=True, request_fields=('id',), path='tasklist/{id}', http_method='GET', name='tasklist.get')
    def TaskListGet(self, a_task_list):
        """ Simple get to return one TaskUser from the one email given. """
        if not a_task_list.from_datastore:
            raise endpoints.NotFoundException("TaskList not found.")
        return a_task_list

    # This delete is bad because it's the exact same GET request as the get above.

    @TaskList.method(user_required=True, request_fields=('id',), path='tasklist/delete/{id}', http_method='GET', name='tasklist.delete')
    def TaskListDelete(self, a_task_list):
        """ Delete a TaskList. """
        if not a_task_list.from_datastore:
            raise endpoints.NotFoundException("TaskList not found.")
        # Delete all the tasks
        for a_task_key in a_task_list.tasks:
            a_task_key.delete()
        # Remove all the references in the TaskUsers
        a_task_list.flush_task_users_list()
        a_task_list.key.delete()
        return TaskList(title="deleted")

APPLICATION = endpoints.api_server([RoseTaskApi],
                                   restricted=False)
