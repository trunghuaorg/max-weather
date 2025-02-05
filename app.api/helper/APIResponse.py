import json


class APIMessageResponse:
    def response(self, code: int, message: str, data: object):
        return json.dumps({
            'Code': code,
            'Message': message,
            'Data': data
        })


class APICodeResponse:
    OK_Code = 0
    Failed_Code = 1

    Successed = "Successed"
    NotOK = "Empty data"
    InvalidEndpointSupport = "Invalid endpoint support"
    InvalidParameter = "Invalid parameter"
    InvalidSecretKey = "Invalid secret key"
