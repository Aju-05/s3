import boto3
import os

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    source_bucket = os.environ['SOURCE_BUCKET']
    dest_bucket = os.environ['DEST_BUCKET']

    src = s3.Bucket(source_bucket)
    dest = s3.Bucket(dest_bucket)

    for obj in src.objects.all():
        dest.copy({'Bucket': source_bucket, 'Key': obj.key}, obj.key)

    return {'status': 'done'}
