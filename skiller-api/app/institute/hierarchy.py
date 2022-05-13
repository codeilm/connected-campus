import strawberry  # For working with GraphQL
from typing import Union, Any, List, Optional # To work with Union and Any data type
from app.db import *

@strawberry.type
class Hierarchy:
    id: int
    path: str


def get_hierarchies_resolver() -> List[Hierarchy]:
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT * from hierarchy;'
    cur.execute(query)
    raw_hieararchies = cur.fetchall()
    close_db(con,cur)
    hierarchies = []
    for raw_hieararchy in raw_hieararchies:
        hierarchies.append(Hierarchy(
            id=raw_hieararchy[0],
            path=raw_hieararchy[1]
        ))
    return hierarchies