from flask import Flask


def create_app(config_name=None):
    from .main.views import s3_form

    app = Flask(__name__)
    app.register_blueprint(s3_form)
    app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'

    return app
