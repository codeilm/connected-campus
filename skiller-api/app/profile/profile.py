import strawberry  # For working with GraphQL
from strawberry.types import Info # For checking authenticity in IsAuthentic class

from app.db import *
from app.auth.login import get_user_id


def update_profile_resolver( info:Info, fcm_token : str) -> bool:
    user_id = get_user_id(info)
    con = connect_db()
    cur = con.cursor()
    sql = 'UPDATE people SET fcm_token=%s WHERE id=%s;'
    cur.execute(sql, [fcm_token,user_id])
    # user_data = cur.fetchone()
    close_db(con,cur)
    # if user_data:
    #     return True
    return True


