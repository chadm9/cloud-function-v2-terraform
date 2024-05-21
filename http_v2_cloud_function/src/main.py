import json
import os
from google.cloud import secretmanager
import flask
import functions_framework



@functions_framework.http
def hello(request: flask.Request) -> flask.typing.ResponseReturnValue:

    print("Function Execution Started")

    return "Hello"


