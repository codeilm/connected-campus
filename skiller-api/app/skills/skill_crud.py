import strawberry  # For working with GraphQL
from strawberry.types import Info
from typing import Union, Any, List, Optional # To work with Union and Any data type

from app.auth.login import get_user_id
from app.db import connect_db, close_db  # for working with Database


@strawberry.type 
class Skill:
    id: int
    name: str

def add_skill_resolver(info : Info, skill_id: int)-> bool:
    user_id = get_user_id(info)
    if(user_id and skill_id):
        con = connect_db()
        cur = con.cursor()
        sql = 'INSERT INTO having_skill (user_id, skill_id) VALUES (%s,%s);'
        cur.execute(sql,[user_id, skill_id])
        close_db(con,cur)
        return True
    return False

def get_skills_resolver(user_id : str)-> List[Skill]:
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT having_skill.skill_id, skill_dataset.name from having_skill LEFT JOIN skill_dataset ON having_skill.skill_id=skill_dataset.id WHERE having_skill.user_id=%s;'
    cur.execute(query,[user_id])
    skill_tuples = cur.fetchall()
    close_db(con,cur)
    skills = []
    for skill_tuple in skill_tuples:
        skills.append(Skill(
            id=skill_tuple[0],
            name=skill_tuple[1]
        ))
    return skills

def delete_skill_resolver(info : Info, skill_id: int)-> bool:
    user_id = get_user_id(info)
    if(user_id and skill_id):
        con = connect_db()
        cur = con.cursor()
        sql = 'DELETE FROM having_skill WHERE user_id=%s AND skill_id=%s;'
        cur.execute(sql,[user_id, skill_id])
        close_db(con,cur)
        return True
    return False

def search_skills_by_keyword_resolver(keyword : str)-> List[Skill]:
    con = connect_db()
    cur = con.cursor()
    query = f"SELECT id, name from skill_dataset where name iLIKE \'%{keyword}%\';"
    cur.execute(query)
    skill_tuples = cur.fetchall()
    close_db(con,cur)
    skills = []
    for skill_tuple in skill_tuples:
        skills.append(Skill(
            id=skill_tuple[0],
            name=skill_tuple[1]
        ))
    return skills
