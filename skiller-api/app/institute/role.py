import strawberry  # For working with GraphQL
from typing import Union, Any, List, Optional # To work with Union and Any data type
from app.db import *


@strawberry.type
class Role:
    id: int
    name: str


def get_roles_resolver() -> List[Role]:
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT * from role;'
    cur.execute(query)
    raw_roles = cur.fetchall()
    close_db(con,cur)
    roles = []
    for raw_role in raw_roles:
        roles.append(Role(
            id=raw_role[0],
            name=raw_role[1]
        ))
    return roles
