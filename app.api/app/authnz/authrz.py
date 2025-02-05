import jwt
import datetime
import logging
from app.appconfig import app
from passlib.hash import pbkdf2_sha256
import re 
from helper.logger_config import logger

fake_users_db = {
    "fake_snake": {
        "username": "fake_snake",
        "hash_password": "$pbkdf2-sha256$29000$kFLKeQ/B.N97T8n5n3OuVQ$1qrZTHvGvOQRZdmSiormygS08Lc9d3U98m8HJc.Kyg8",
        "raw_password:" : "SS_br!333",
        "email": "dummy@dummy.com",
        "attribute" : ["writer", "editor"] 
    },
    "fake_dummy": {
        "username": "fake_dummy",
        "hash_password": "$pbkdf2-sha256$29000$kFLKeQ/B.N97T8n5n3OuVQ$1qrZTHvGvOQRZdmSiormygS08Lc9d3U98m8HJc.Kyg8",
        "raw_password": "SS_br!333",
        "email": "dummy@dummy.com",
        "attribute" : ["writer", "editor"] 
    }
}

class UserLoginProfile:

    @staticmethod
    def filter_input(user_input):
        # Remove common SQL injection patterns
        sanitized_input = re.sub(r"[;'\"--]", "", user_input)
        sanitized_input = re.sub(r"(;|\b(UNION|SELECT|INSERT|DELETE|UPDATE|DROP|EXEC|ALTER|CREATE|REPLACE)\b)", "", sanitized_input, flags=re.IGNORECASE)
        return sanitized_input
    
    @staticmethod
    def find_by_username_and_password(username:str) :
        logger.info(f'start search user: {username}')
        if fake_users_db.get(username, None):
            return {
                "username": fake_users_db[username]["username"],
                "password": fake_users_db[username]["hash_password"],
                "email": fake_users_db[username]["email"],
                "attribute": fake_users_db[username]["attribute"],
            }
        return False


class UserLoginVerify:
    @staticmethod
    def verify_user_account_access(username: str, password: str, SECRET_KEY: str):
        username=UserLoginProfile.filter_input(username.strip().lower())
        find_user_by_credential = UserLoginProfile.find_by_username_and_password(username=username)
        if find_user_by_credential:
            logger.info(f"search data for user: {username}")
            password_verify = pbkdf2_sha256.verify(password, find_user_by_credential['password'])
            if password_verify:
                return {
                    "message": "Welcome to sknynet",
                    "code": 0,
                    "permit": True,
                    "AccessToken": UserLoginVerify.generate_token(find_user_by_credential["username"], find_user_by_credential["attribute"], SECRET_KEY),
                    "UserScopes":  find_user_by_credential["attribute"]
                }
        else:
            logger.error(f"can not process or found the user as username: {username}")
            return {
                "message" : "The account not exits in our system",
                "code": 1,
                "permit": False,
                "AccessToken": None,
                "UserScopes": []
            }
    
    @staticmethod
    def generate_token(user_id, user_scopes, SECRET_KEY):
        token = jwt.encode({
            'user_id': user_id,
            'user_scops': user_scopes,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)
        }, SECRET_KEY, algorithm='HS256')
        return token
    
    @staticmethod
    def passwordhashconvert(password: str) -> str:
        hashed_password = pbkdf2_sha256.hash(password)
        print(f'encryption password result: {hashed_password}')
        return hashed_password
    