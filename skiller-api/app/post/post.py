import strawberry  # For working with GraphQL
from typing import Union, Any, List, Optional # To work with Union and Any data type
from datetime import date, datetime, timedelta  # To work with datetime
from strawberry.types import Info # For checking authenticity in IsAuthentic class

from app.db import *
from app.auth.login import get_user_id


@strawberry.type
class Post:
    id: int
    image_url: str
    post_title: str
    description: str
    for_whom: List[int]
    user_id: str
    unofficial_username: str
    user_photo_url: str
    user_title: str
    user_type_id: int
    post_type_id : int
    total_likes : int
    total_comments : int
    is_liked:bool
    attachments: Optional[List[str]] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


def add_post_resolver(info:Info,post_type_id: int, image_url: str, title: str, description: str, for_whom: List[int], attachments: Optional[List[str]] = None) -> bool:
    user_id = get_user_id(info)
    query = 'INSERT INTO post (user_id, post_type_id, image_url, attachments, title, description, for_whom) VALUES (%s,%s,%s,%s,%s,%s,%s) RETURNING id;'
    cur.execute(query, [user_id, post_type_id, image_url, attachments,
                title, description, for_whom])
    # cur.execute('SELECT last_value FROM post_id_seq;')
    # post_id = (cur.fetchone())[0]
    # print(f'Post ID {post_id}')
    conn.commit()
    return True


def get_post_resolver(post_id: int) -> Post:
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT id, user_id, image_url, attachments, title, description, for_whom, created_at, updated_at FROM post WHERE id = %s;'
    cur.execute(query, [post_id])
    raw_post = cur.fetchone()
    close_db(con,cur)

    return Post(
        id=raw_post[0],
        user_id=raw_post[1],
        image_url=raw_post[2],
        attachments=raw_post[3],
        title=raw_post[4],
        description=raw_post[5],
        for_whom=raw_post[6],
        created_at=raw_post[7],
        updated_at=raw_post[8])


def get_posts_resolver(info : Info,  post_type_id : Optional[int] = None, is_for_only_current_user :Optional[bool]  = False) -> List[Post]:
    con = connect_db()
    cur = con.cursor()
    user_id = get_user_id(info)
    # Condition for all types of posts
    if post_type_id == None:
        if is_for_only_current_user:  # For profile screen posts
            query = 'SELECT post.id, post_type_id, user_id, post.image_url, post.title, attachments, for_whom, post.created_at, post.updated_at, people.unofficial_name, photo_url, people.title, people.role AS user_type_id, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id) as total_likes,(SELECT COUNT(comment.id) FROM comment WHERE comment.post_id=post.id) as total_comments, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id AND likes.user_id=%s) as is_liked FROM post LEFT JOIN people ON post.user_id = people.id WHERE post.user_id=%s ORDER BY created_at DESC;'
            cur.execute(query,[user_id,user_id])
        else: # For Home Screen posts
            query = 'SELECT post.id, post_type_id, user_id, post.title AS post_title, post.description, attachments, for_whom, post.created_at, post.updated_at, people.unofficial_name, photo_url, people.title AS user_title, people.role AS user_type_id, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id) as total_likes,(SELECT COUNT(comment.id) FROM comment WHERE comment.post_id=post.id) as total_comments, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id AND likes.user_id=%s) as is_liked FROM post LEFT JOIN people ON post.user_id = people.id ORDER BY created_at DESC;'
            cur.execute(query,[user_id])
    else:
        if is_for_only_current_user:  # For profile screen projects
            query = 'SELECT post.id,  post.image_url, post.title AS post_title, post.description, attachments, for_whom, post.created_at, post.updated_at, people.unofficial_name, photo_url, people.title AS user_title, people.role AS user_type_id, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id) as total_likes,(SELECT COUNT(comment.id) FROM comment WHERE comment.post_id=post.id) as total_comments, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id AND likes.user_id=%s) as is_liked FROM post LEFT JOIN people ON post.user_id = people.id WHERE post_type_id=%s AND post.user_id=%s ORDER BY created_at DESC;'
            cur.execute(query,[user_id,post_type_id,user_id])
        else:
            query = 'SELECT post.id, post_type_id, user_id, post.image_url, post.title AS post_title, post.description, attachments, for_whom, post.created_at, post.updated_at, people.unofficial_name, photo_url, people.title AS user_title, people.role AS user_type_id, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id) as total_likes,(SELECT COUNT(comment.id) FROM comment WHERE comment.post_id=post.id) as total_comments, (SELECT COUNT(likes.user_id) FROM likes WHERE likes.post_id=post.id AND likes.user_id=%s) as is_liked FROM post LEFT JOIN people ON post.user_id = people.id WHERE post_type_id=%s ORDER BY created_at DESC;'
            cur.execute(query,[user_id,post_type_id])
    raw_posts = cur.fetchall()
    close_db(con,cur)

    posts = []
    for raw_post in raw_posts:
        posts.append(Post(
            id=raw_post[0],
            post_type_id = raw_post[1],
            user_id=raw_post[2],
            image_url=raw_post[3],
            post_title=raw_post[4],
            description=raw_post[5],
            attachments = raw_post[6],
            for_whom=raw_post[7],
            created_at=raw_post[8],
            updated_at=raw_post[9],
            unofficial_username = raw_post[10],
            user_photo_url = raw_post[11],
            user_title = raw_post[12],
            user_type_id = raw_post[13],
            total_likes = raw_post[14],
            total_comments = raw_post[15],
            is_liked = raw_post[16]==1
            )
        ) 
    return posts


def update_post_resolver(post_id: int, image_url: str, title: str, description: str, for_whom: List[int]) -> Post:
    query = 'UPDATE post SET  title = %s, description = %s, for_whom = %s WHERE id = %s;'
    cur.execute(query, [image_url, title, description, for_whom, post_id])
    conn.commit()
    return Post(id=post_id,
                # user_id = user_id,
                image_url=image_url,
                title=title,
                description=description,
                for_whom=[5],
                updated_at=datetime.now())


def delete_post_resolver(post_id: int) -> bool:
    query = 'DELETE FROM post WHERE id = %s'
    cur.execute(query, [post_id])
    conn.commit()
    return True