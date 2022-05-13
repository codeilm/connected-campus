from app.db import connect_db, close_db  #for working with Database
import strawberry  # For working with GraphQL
import strawberry.fastapi  # For Strawberry with FaskAPI

# To work with Union and Any data type
from typing import Union, Any, List, Optional

from strawberry.types import Info


#search the profile and skill by prefix
@strawberry.type
class Search_result:
    id: str
    name: str
    type: int

@strawberry.type
class Search_result_no_data:
    msg: str

@strawberry.type
class Search_result_list:
    Search_result_list_variable: List[Search_result]


Search_result_union = strawberry.union('Search_result_union', types=(Search_result_list, Search_result_no_data))

def get_search_result(keyword: str) -> Search_result_union:
    print('in modal to get_search_result')
    con=connect_db()
    cur = con.cursor()
    sql=f'SELECT id, name, 1 as type FROM skill_dataset WHERE name iLIKE \'%{keyword}%\' limit 4;'
    cur.execute(sql)
    fetched_data=cur.fetchall()

    sql=f'SELECT id, unofficial_name as name, 2 as type FROM people WHERE unofficial_name iLIKE \'%{keyword}%\' limit 4'
    cur.execute(sql)
    fetched_data2=cur.fetchall()

    close_db(con,cur)
    print(fetched_data)
    if (fetched_data or fetched_data2): 
        payload = []
        for tupple in fetched_data:
            payload.append(Search_result(id=tupple[0],
            name=tupple[1],
            type=tupple[2])) #here type 1 indicates skill name is searched
        for tupple in fetched_data2:
            payload.append(Search_result(id=tupple[0],
            name=tupple[1],
            type=tupple[2])) #here type 2 indicates person name is searched
        return Search_result_list(Search_result_list_variable=payload)
    else: 
        print('no data found')
        return Search_result_no_data(msg="no data found")


#search by skill -all people belonging to that skill
@strawberry.type
class Search_by_skill_result:
    id: str
    name: str
    title: str
    photo_url:str
 

@strawberry.type
class Search_by_skill_result_list:
    Search_by_skill_result_list_variable: List[Search_by_skill_result]
 

Search_by_skill_result_union = strawberry.union('Search_by_skill_result_union', types=(Search_by_skill_result_list, Search_result_no_data))

def get_search_by_skill_result(skill_id: int) -> Search_by_skill_result_union:
    print('in modal to get_search_by_skill_result')
    con=connect_db()
    cur = con.cursor()
    sql=f'Select people.id, people.unofficial_name, people.title, people.photo_url from having_skill Join skill_dataset on having_skill.skill_id = skill_dataset.id Join people on having_skill.user_id = people.id where having_skill.skill_id={skill_id}'
    cur.execute(sql)
    fetched_data=cur.fetchall()
    close_db(con,cur)
    print(fetched_data)
    if (fetched_data): 
        payload = []
        for tupple in fetched_data:
            payload.append(Search_by_skill_result( id=tupple[0],name=tupple[1],
            title=tupple[2],
            photo_url=tupple[3]))
        return Search_by_skill_result_list(Search_by_skill_result_list_variable=payload)
    else: 
        print('no data found')
        return Search_result_no_data(msg="no data found")


#search the profile by prefix 


@strawberry.type
class Search_profile_by_prefix_result:
    id: str
    name: str
    title: str
    photo_url: str
 
@strawberry.type
class Search_profile_by_prefix_result_list:
    Search_profile_by_prefix_result_variable: List[Search_profile_by_prefix_result]



    
Search_profile_by_prefix_union = strawberry.union('Search_profile_by_prefix_union', types=(Search_profile_by_prefix_result_list, Search_result_no_data))

def get_search_profile_by_prefix_result(keyword: str) -> Search_profile_by_prefix_union:
    print('in modal to get_search_result')
    con=connect_db()
    cur = con.cursor()
    sql=f'SELECT id, unofficial_name, photo_url,title FROM people WHERE unofficial_name iLIKE \'%{keyword}%\' limit 4'
    cur.execute(sql)
    fetched_data=cur.fetchall()
    close_db(con,cur)
    print(fetched_data)
    if (fetched_data): 
        payload = []
        for tupple in fetched_data:
            payload.append(Search_profile_by_prefix_result(id=tupple[0],
            name=tupple[1],
            photo_url=tupple[2], title=tupple[3]))
        
        return Search_profile_by_prefix_result_list(Search_profile_by_prefix_result_variable=payload)
    else: 
        print('no data found')
        return Search_result_no_data(msg="no data found")

