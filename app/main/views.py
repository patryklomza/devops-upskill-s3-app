import logging

from botocore.exceptions import ClientError
from botocore.client import Config
from flask import abort
from flask import Blueprint, render_template
from jinja2 import TemplateNotFound

import boto3

s3_form = Blueprint('s3_form', __name__)

BUCKET_NAME = 'plomza-bucket'
OBJECT_NAME = '${filename}'

session = boto3.session.Session(profile_name='plomza')


def create_presigned_url(bucket_name, object_name, expiration=3600):
    s3_client = session.client('s3')
    try:
        response = s3_client.generate_presigned_url('get_object', Params={'Bucket': bucket_name, 'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None
    return response


def create_presigned_post(bucket_name, object_name,
                          fields=None, conditions=None, expiration=3600):
    """Generate a presigned URL S3 POST request to upload a file

    :param bucket_name: string
    :param object_name: string
    :param fields: Dictionary of prefilled form fields
    :param conditions: List of conditions to include in the policy
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Dictionary with the following keys:
        url: URL to post to
        fields: Dictionary of form fields and values to submit with the POST
    :return: None if error.
    """

    # Generate a presigned S3 POST URL
    s3_client = boto3.client('s3', config=Config(signature_version='s3v4'))
    try:
        response = s3_client.generate_presigned_post(bucket_name,
                                                     object_name,
                                                     Fields=fields,
                                                     Conditions=conditions,
                                                     ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response


@s3_form.route('/s3', methods=['POST', 'GET'])
def form():
    try:
        presigned_response = create_presigned_post(bucket_name=BUCKET_NAME, object_name=OBJECT_NAME)

        return render_template('s3_form.html', response=presigned_response)
    except TemplateNotFound:
        abort(404)


@s3_form.route('/s3/files')
def get_objects():
    resource = session.resource('s3')
    my_bucket = resource.Bucket('plomza-bucket')
    objects = my_bucket.objects.all()
    data = [(obj.key, create_presigned_url('plomza-bucket', obj.key)) for obj in objects]
    return render_template('files.html', data=data)
