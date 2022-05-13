import strawberry  # For working with GraphQL
from typing import Union, Any, List, Optional # To work with Union and Any data type
from app.db import *
from datetime import date, datetime, timedelta  # To work with datetime
from strawberry.types import Info # For checking authenticity in IsAuthentic class



@strawberry.type
class Comment:
    id: int
    post_id: str
    user_id: str
    message: str
    created_at: datetime
    path: Optional[str] = None
    updated_at: Optional[datetime] = None

def add_comment_resolver(info : Info,post_id: int, message: str, path: Optional[str] = None) -> Comment:
    user_id = get_user_id(info)
    con = connect_db()
    cur = con.cursor()
    query = 'INSERT INTO comment (path,post_id,user_id,message) VALUES (%s,%s,%s,%s) RETURNING id;'
    cur.execute(query, [path, post_id, user_id, message])
    close_db(con,cur)
    comment_id = (cur.fetchone())[0]

    if path is None:
        path = str(comment_id)
    else:
        path += '.'+str(comment_id)

    query = 'UPDATE comment SET path = %s WHERE id = %s;'
    cur.execute(query,[path,comment_id])
    conn.commit()
    # After adding the post, returning the same post
    return Comment(id=comment_id,
                   post_id=post_id,
                   user_id=user_id,
                   message=message,
                   created_at=datetime.now(),
                   path = path
                   )

def get_comments_resolver() -> List[Comment]:
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT * from comment;'
    cur.execute(query)
    raw_comments = cur.fetchall()
    close_db(con,cur)
    comments = []
    for raw_comment in raw_comments:
        print(raw_comment)
        comments.append(Comment(
            id=raw_comment[0],
            path=raw_comment[1],
            post_id=raw_comment[2],
            user_id=raw_comment[3],
            message=raw_comment[4],
            created_at=raw_comment[5],
            updated_at=raw_comment[6]
        ))
    return comments

def update_comment_resolver(message: str, id : int) -> bool:
    query = 'UPDATE comment SET message = %s , updated_at = %s WHERE id = %s;'
    cur.execute(query,[message,dt.datetime.now(),id])
    conn.commit()
    return True

def delete_comment_resolver(id : int) -> bool:
    query = 'DELETE FROM comment WHERE id = %s'
    cur.execute(query, [id])
    conn.commit()
    return True
