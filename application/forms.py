from flask_wtf import FlaskForm
from wtforms import TextField, BooleanField, TextAreaField, SubmitField, validators

class TestDBForm(FlaskForm):
    name = TextField("Name", [validators.required()])
    message = TextAreaField("Message", [validators.required()])
    submit = SubmitField("Send", [validators.required()])
