# To work with Union and Any data type
from typing import Any, List, Optional, Union

import strawberry  # For working with GraphQL
import strawberry.fastapi  # For Strawberry with FaskAPI
from strawberry.types import Info

from app.db import connect_db, close_db  # for working with Database
from app.auth.login import get_user_id
from app.notifications.notification import send_notification_to_specific_device


#send connection request.
@strawberry.type
class acknowledge:
    msg: str
    code: int

# add connection request to connection 
def send_connection_request(info : Info, reciever_user_id: str, message: str)-> acknowledge:
    sender_user_id = get_user_id(info)
    if(sender_user_id and reciever_user_id and message):
        con=connect_db()
        cur = con.cursor()
        sql = f'WITH ins1 AS ( INSERT INTO connection(sender_user_id, reciever_user_id) VALUES (\'{sender_user_id}\', \'{reciever_user_id}\') RETURNING id) SELECT id, \'{message}\' FROM ins1 returning id;'
        cur.execute(sql)
        fetched_data=cur.fetchone()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            send_connection_notification(sender_user_id = sender_user_id, reciever_user_id=reciever_user_id,message=message)
            return acknowledge(msg="connection sent", code=1)
        else: return acknowledge(msg="connection not sent", code=2)
    else:
        return acknowledge(msg="invalid data", code=3)

def send_connection_notification(sender_user_id : str, reciever_user_id : str,message :str):
    con=connect_db()
    cur = con.cursor()
    sql = 'SELECT unofficial_name,  photo_url, (SELECT fcm_token  FROM people WHERE id=%s) as fcm_token  FROM people WHERE id=%s;'
    # After testing uncommen the below line and remove the next line
    # cur.execute(sql,[reciever_user_id, sender_user_id])
    cur.execute(sql,[sender_user_id, sender_user_id])
    fetched_data=cur.fetchone()
    official_name, photo_url, fcm_token = fetched_data[0], fetched_data[1], fetched_data[2]
    print(f'data for notification : {official_name}, {photo_url}, {fcm_token}')
    title = f'{official_name} wants to connect'
    send_notification_to_specific_device(fcm_token=fcm_token,title=title,body=message,image=photo_url)



#reject connection request
def reject_connection_request(id: int, message: str)-> acknowledge:
    if(isinstance(id,int) and isinstance(message,str) and message is not None ):
        con=connect_db()
        cur = con.cursor()
        sql = 'UPDATE connection_message SET reply = %s, allow = False, response_at=NOW() WHERE id=%s returning id;'
        cur.execute(sql,(message,id))
        fetched_data=cur.fetchone()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            return acknowledge(msg="connection rejected", code=1)
        else: return acknowledge(msg="connection not rejected", code=2)
    else:
        return acknowledge(msg="invalid data", code=3)

#allow the connection request
def allow_connection_request(id: int)-> acknowledge:
    if(isinstance(id,int)):
        con=connect_db()
        cur = con.cursor()
        sql = 'UPDATE connection_message SET allow = True, response_at=NOW() WHERE id=%s returning id;'
        cur.execute(sql, (id,))
        fetched_data=cur.fetchone()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            return acknowledge(msg="connection Formed", code=1)
        else: return acknowledge(msg="connection not formed", code=2)
    else:
        return acknowledge(msg="invalid data", code=3)


#Terminate connection request
def terminate_connection_request(id: int)-> acknowledge:
    if(isinstance(id,int)):
        con=connect_db()
        cur = con.cursor()
        sql = 'WITH ins1 AS(DELETE from connection where id=%s returning sender_user_id, reciever_user_id, created_at) INSERT INTO connection_history (sender_user_id,reciever_user_id,sender_message, reply, allowed, created_at, reply_at) SELECT ins1.sender_user_id, ins1.reciever_user_id, ins2.sender_message, ins2.reply, ins2.allow,ins1.created_at, ins2.response_at from ins1, ins2 returning id;'
        cur.execute(sql, (id,id))
        fetched_data=cur.fetchone()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            return acknowledge(msg="connection terminated", code=1)
        else: return acknowledge(msg="connection not terminated", code=2)
    else:
        return acknowledge(msg="invalid data", code=3)





#Terminate connected connection
def terminate_connected_connection(id: int)-> acknowledge:
    if(isinstance(id,int)):
        con=connect_db()
        cur = con.cursor()
        sql = 'WITH ins1 AS(DELETE from connection where id=%s returning sender_user_id, reciever_user_id, created_at) INSERT INTO connection_history (sender_user_id,reciever_user_id,sender_message, allowed, created_at, reply_at) SELECT ins1.sender_user_id, ins1.reciever_user_id, ins2.sender_message, ins2.allow,ins1.created_at, ins2.response_at from ins1, ins2 returning id;'
        cur.execute(sql,(id,id))
        fetched_data=cur.fetchone()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            return acknowledge(msg="connection terminated", code=1)
        else: return acknowledge(msg="connection not terminated", code=2)
    else:
        return acknowledge(msg="invalid data", code=3)

 



@strawberry.type
class my_conenction:
    id: str
    name: str
    title: str
    photo_url: str
    rec_or_sent: int
    connection_id: int

 
@strawberry.type
class my_conenction_list:
    my_conenction_list_variable: List[my_conenction]



    
my_conenction_list_union = strawberry.union('my_conenction_list_union', types=(my_conenction_list, acknowledge))

#view all connection
def view_connected_connection(info: Info)-> my_conenction_list_union:
    id = get_user_id(info)
    if(isinstance(id,str)):
        con=connect_db()
        cur = con.cursor()
        sql = 'With ins1 as( select con.sender_user_id, con.id, 1 as type from connection con Join connection_message conm on con.id=conm.id where allow= true and reciever_user_id=%s) select pe.id, pe.unofficial_name, pe.title, pe.photo_url, ins1.type, ins1.id from people pe join ins1 on pe.id=ins1.reciever_user_id union select pe.id, pe.unofficial_name, pe.title, pe.photo_url, ins2.type, ins2.id from people pe join ins2 on pe.id=ins2.sender_user_id'
        cur.execute(sql,(id,id))
        fetched_data=cur.fetchall()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            payload = []
            for tupple in fetched_data:
                payload.append(my_conenction(
                    id=tupple[0],
                name=tupple[1],
                title=tupple[2],
                photo_url=tupple[3],
                rec_or_sent=tupple[4],
                connection_id=tupple[5]
                ))
            
            return my_conenction_list(my_conenction_list_variable=payload)

        else: return acknowledge(msg="No data found", code=2)
    else:
        return acknowledge(msg="invalid requested data", code=3)



#view all connection in progress
def view_in_progress_connection(info: Info)-> my_conenction_list_union:
    id = get_user_id(info)
    if(isinstance(id,str)):
        con=connect_db()
        cur = con.cursor()
        sql = 'with ins1 as(select con.reciever_user_id, con.id, 2 as type from connection con Join connection_message conm on con.id=conm.id where con.sender_user_id=%s and (conm.allow is null or conm.allow=False )), ins2 as(select con.sender_user_id, con.id, 1 as type from connection con Join connection_message conm on con.id=conm.id where con.reciever_user_id=%s and (conm.allow is null or conm.allow=False )) select pe.id, pe.unofficial_name, pe.title, pe.photo_url, ins1.type, ins1.id from people pe join ins1 on pe.id=ins1.reciever_user_id union select pe.id, pe.unofficial_name, pe.title, pe.photo_url, ins2.type, ins2.id from people pe join ins2 on pe.id=ins2.sender_user_id'
        cur.execute(sql,(id,id))
        fetched_data=cur.fetchall()
        print("id is fetched ", fetched_data)
        close_db(con,cur)
        if(fetched_data):
            payload = []
            for tupple in fetched_data:
                payload.append(my_conenction(
                    id=tupple[0],
                name=tupple[1],
                title=tupple[2],
                photo_url=tupple[3],
                rec_or_sent=tupple[4],
                connection_id=tupple[5]

                ))
            
            return my_conenction_list(my_conenction_list_variable=payload)

        else: return acknowledge(msg="No data found", code=2)
    else:
        return acknowledge(msg="invalid requested data", code=3)




