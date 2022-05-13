import strawberry  # For working with GraphQL
from typing import Union, Any, List, Optional # To work with Union and Any data type
from datetime import date, datetime, timedelta  # To work with datetime
from app.db import *

@strawberry.type
class Session:
    id: str
    token: str
    expiry_date: date


def get_sessions_resolver() -> List[Session]:
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT * from session;'
    cur.execute(query)
    raw_sessions = cur.fetchall()
    close_db(con,cur)
    sessions = []
    for raw_session in raw_sessions:
        sessions.append(Session(
            id=raw_session[0],
            token=raw_session[1],
            expiry_date=raw_session[2]
        ))
    return sessions