import strawberry  # For working with GraphQL
import bcrypt  # For Hashing and Authentication
from strawberry.types import Info # For checking authenticity in IsAuthentic class

from app.db import *
from app.auth.auth import generate_token, SECRET_KEY, SECURITY_ALGORITHM


@strawberry.type
class User:
    unofficial_name: str
    title: str
    description : str
    phone: str
    photo_url : str

@strawberry.type
class LoginSuccess:
    user: User
    token: str


@strawberry.type
class LoginError:
    message: str


LoginResult = strawberry.union('LoginResult', types=(LoginSuccess, LoginError))


def login_resolver(phone: str, password: str) -> LoginResult:
    con = connect_db()
    cur = con.cursor()
    sql = 'SELECT id, unofficial_name, title, phone, password, photo_url, description FROM people WHERE phone=%s;'
    cur.execute(sql, [phone])
    user_data = cur.fetchone()
    if user_data:
        hashed_password = user_data[4]
        if bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8')):
            jwt_token = generate_token()
            hashed_token = (bcrypt.hashpw(jwt_token.encode(
                'utf-8'), SECRET_KEY.encode('utf-8'))).decode('utf-8')
            sql = 'INSERT INTO Session (user_id,token) VALUES (%s,%s) ON CONFLICT (user_id) DO UPDATE SET token = %s;'
            cur.execute(sql, [user_data[0], hashed_token, hashed_token])
            close_db(con,cur)
            return LoginSuccess(user=User(unofficial_name=user_data[1], title=user_data[2], phone=user_data[3],photo_url = user_data[5],description = user_data[6]), token=jwt_token)

        return LoginError(message='Wrong Phone number or Password')
    return LoginError(message='Either phone number is wrong or account does not exists')

def get_user_id(info : Info)->str:
    request: typing.Union[Request, WebSocket] = info.context["request"]
    token = request.headers['authorization']
    hashed_token = (bcrypt.hashpw(token.encode('utf-8'),
                    SECRET_KEY.encode('utf-8'))).decode('utf-8')
    con = connect_db()
    cur = con.cursor()
    query = 'SELECT user_id FROM session WHERE token = %s'
    cur.execute(query, [hashed_token])
    user_data = cur.fetchone()
    close_db(con,cur)
    print(f'User Data : {user_data}')
    if user_data:
        return user_data[0]
    else:
        return None

