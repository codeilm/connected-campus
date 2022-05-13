import psycopg2

def connect_db():    
    # con = psycopg2.connect(
    #     host="localhost",
    #     database="test",
    #     user="postgres",
    #     password="postgres")

    # Get this credentials from Heroku
    con = psycopg2.connect(
        host="ec2-3-216-40-16.compute-1.amazonaws.com",
        database="dajt1r5vkqkqjf",
        user="gslkpsidxrywwy",
        password="0aff7df308d5eff8521c792d419e9d15be29f4696b7bf54e3670c514fc25181c")
    return con

def close_db(con, cur):
    con.commit()
    cur.close()
    con.close()