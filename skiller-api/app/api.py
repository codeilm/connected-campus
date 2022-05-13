import strawberry  # For working with GraphQL
import fastapi  # For FastAPI Framewok
import datetime as dt
import strawberry.fastapi  # For Strawberry with FaskAPI

from typing import Union, Any, List, Optional # To work with Union and Any data type

from datetime import date, datetime, timedelta  # To work with datetime

import jwt  # it is from pyjwt package, so before using it do, pip install pyjwt

import bcrypt  # For Hashing and Authentication

import psycopg2  # For working with PostgreSQL
from uuid import uuid4  # For generating uuid for Token

from strawberry.permission import BasePermission  # For Protecting unauthorized access
import typing  # For using typing.Union

from strawberry.types import Info # For checking authenticity in IsAuthentic class
# import hashlib # For using SHA

from app.db import connect_db, close_db  #for working with Database

from app.auth.auth import *
from app.auth.session import Session, get_sessions_resolver
from app.auth.login import *

from app.post.post import *
from app.post.comments import *
from app.post.likes import *

from app.institute.hierarchy import *
from app.institute.role import *
from app.profile.profile import *

import app.skills.search_result as search_result_connector
from app.skills.skill_crud import *


import app.connect.connect as connect_connector


app = fastapi.FastAPI()


def welcome_resolver(info : Info) -> str:
    user_id = get_user_id(info)
    return user_id if user_id else ''


@strawberry.type
class UserProfile:
    id: str
    unofficial_name : str
    title : str
    description : str
    photo_url : str
    skills : List[Skill]


def get_user_profile_resolver(info : Info, id : str) -> UserProfile:
    con = connect_db()
    cur = con.cursor()
    user_id = id
    if isinstance(user_id,str) and len(user_id)==0:
        user_id = get_user_id(info)
    query = 'SELECT id, unofficial_name, title, description, photo_url from people WHERE id=%s;'
    cur.execute(query,[user_id])
    raw_profile = cur.fetchone()
    close_db(con,cur)
    return UserProfile(
            id=raw_profile[0],
            unofficial_name=raw_profile[1],
            title=raw_profile[2],
            description=raw_profile[3],
            photo_url = raw_profile[4],
            skills = get_skills_resolver(user_id = user_id)
        )



@strawberry.type
class Query:
    @strawberry.field
    def hello() -> str:
        return f'Welcome to Skiller'
    get_hierarchies: List[Hierarchy] = strawberry.field(
        resolver=get_hierarchies_resolver)
    welcome: str = strawberry.field(
        resolver=welcome_resolver, permission_classes=[IsAuthentic])
   
    get_user_profile: UserProfile = strawberry.field(resolver=get_user_profile_resolver)
    get_post: Post = strawberry.field(resolver=get_post_resolver)
    get_posts: List[Post] = strawberry.field(resolver=get_posts_resolver,permission_classes=[IsAuthentic])
    get_comments: List[Comment] = strawberry.field(
        resolver=get_comments_resolver)
    get_sessions: List[Session] = strawberry.field(
        resolver=get_sessions_resolver)
    search_by_keyword: search_result_connector.Search_result_union = strawberry.field(resolver=search_result_connector.get_search_result)
    search_by_skill_id: search_result_connector.Search_by_skill_result_union=strawberry.field(resolver=search_result_connector.get_search_by_skill_result)
    search_skills_by_keyword: List[Skill] = strawberry.field(resolver=search_skills_by_keyword_resolver)
    # Connections
    view_in_progress_connections: connect_connector.my_conenction_list_union=strawberry.field(resolver=connect_connector.view_in_progress_connection)
    view_connected_connections: connect_connector.my_conenction_list_union=strawberry.field(resolver=connect_connector.view_connected_connection)



@strawberry.type
class Mutation:
    # After testing add the permission classes here, so that only authenticated user can post
    login: LoginResult = strawberry.field(resolver=login_resolver)
    update_profile : bool = strawberry.field(resolver=update_profile_resolver)
    add_post: bool = strawberry.mutation(resolver=add_post_resolver)
    update_post: Post = strawberry.mutation(resolver=update_post_resolver)
    delete_post: bool = strawberry.mutation(resolver=delete_post_resolver)
    add_comment: Comment = strawberry.mutation(resolver=add_comment_resolver)
    add_like: bool = strawberry.mutation(resolver=add_like_resolver)
    delete_skill: bool = strawberry.mutation(resolver=delete_skill_resolver)

    # Connections
    send_connection_request: connect_connector.acknowledge=strawberry.mutation(resolver=connect_connector.send_connection_request)
    terminate_connection_request: connect_connector.acknowledge=strawberry.mutation(resolver=connect_connector.terminate_connection_request)
    terminate_connected_connection: connect_connector.acknowledge=strawberry.mutation(resolver=connect_connector.terminate_connected_connection)
    

schema = strawberry.Schema(Query, Mutation)

graphql_app = strawberry.fastapi.GraphQLRouter(schema)

app.include_router(graphql_app, prefix='/api/v1')
