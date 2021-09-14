import logging
import os

from botocore.exceptions import ClientError
from flask import abort, request, flash, redirect, url_for
from flask import Blueprint, render_template
from jinja2 import TemplateNotFound

import boto3
import requests
from werkzeug.utils import secure_filename

s3_form = Blueprint('s3_form', __name__)
ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'}


session = boto3.session.Session(profile_name='plomza')

def create_presigned_url(bucket_name, object_name, expiration=3600):
    s3_client = session.client('s3')
    try:
        response = s3_client.generate_presigned_url('get_object', Params={'Bucket': bucket_name, 'Key': object_name}, ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None
    return response


@s3_form.route('/', methods=['POST', 'GET'])
def form():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            url = generate_presigned_url('plomza-bucket', key_name=filename)
            files = {'file': file}
            http_response = requests.post(url['url'],data=url['fields'], files=files)
            flash('uploaded')
            return redirect(request.url)
    try:
        return render_template('s3_form.html')
    except TemplateNotFound:
        abort(404)


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def generate_presigned_url(bucket_name, key_name, fields=None, conditions=None, expiration=3600):
    url = session.client('s3').generate_presigned_post(
        bucket_name,
        key_name,
        ExpiresIn=expiration)
    return url

@s3_form.route('/files')
def get_objects():
    client = session.resource('s3')
    my_bucket = client.Bucket('plomza-bucket')
    objects = my_bucket.objects.all()
    objects_names_list = [object.key for object in objects]


    presigned_url_list = [create_presigned_url('plomza-bucket', object.key) for object in objects ]
    data = zip(objects_names_list, presigned_url_list)
    return render_template('files.html', data=data)


