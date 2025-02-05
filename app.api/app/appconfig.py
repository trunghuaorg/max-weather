
from dotenv import dotenv_values
from flask import Flask, request, Response

import os

config = dotenv_values('.env')
app = Flask(__name__)


app.config["LOG_TYPE"] = os.environ.get("LOG_TYPE", "stream")
app.config["LOG_LEVEL"] = os.environ.get("LOG_LEVEL", "INFO")