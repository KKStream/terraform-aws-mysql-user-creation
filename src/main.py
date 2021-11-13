import json
import logging
import os

import boto3

import pymysql


def handler(event, context):
    logger = logging.getLogger(__name__)
    logging.basicConfig(level=logging.INFO)
    logger.setLevel(logging.INFO)
    
    master_arn = os.getenv('SECRETS_RDS_MASTER_ARN')
    user_arn = os.getenv('SECRETS_RDS_USER_ARN')

    client = boto3.client('secretsmanager')
    master = json.loads(client.get_secret_value(SecretId=master_arn).get('SecretString'))
    user = json.loads(client.get_secret_value(SecretId=user_arn).get('SecretString'))
    logger.info(f'Get user information.')

    endpoint = event.get("DB_ENDPOINT")
    db_name = event.get("DB_NAME")
    port = event.get("DB_PORT")

    conn = pymysql.connect(host=endpoint,
                           port=port,
                           user=master['username'],
                           password=master['password'],
                           db=db_name)
    cursor = conn.cursor()

    cursor.execute(f"""SELECT 1 FROM mysql.user WHERE user='{user["username"]}'""")
    rs = cursor.fetchall()

    if rs:
        logger.info(f'User: {user["username"]} is exists.')
        return

    cursor.execute(f"""SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='{db_name}'""")
    rs = cursor.fetchall()

    if rs:
        logger.info(f'DB ({db_name}) not found. Creating...')
        cursor.execute(f'CREATE DATABASE {db_name};')

    logger.info(f'Creating user "{user["username"]}".')
    cursor.execute(f"""
        CREATE USER {user["username"]}@'%' IDENTIFIED BY '{user["password"]}';
        GRANT ALL PRIVILEGES ON {db_name}.* TO {user["username"]}@'%';
    """)
    conn.commit()
    logger.info(f'User "{user["username"]}" created successfully.')

    pymysql.connect(host=endpoint,
                    port=port,
                    user=user['username'],
                    password=user['password'],
                    db=db_name)
    logger.info(f'User "{user["username"]}" login successfully.')
