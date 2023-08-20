import os.path
import sys

import boto3
import click
import logging

logging.basicConfig(
    stream=sys.stdout,
    format="[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s",
    level=logging.DEBUG,
)

s3 = boto3.resource("s3")


@click.command(help="upload a file to s3.  upload.py bucket file-name")
@click.argument("bucket")
@click.argument("file_name", type=click.Path(exists=True))
def upload_file(bucket=None, file_name=None):
    with open(file_name, "rb") as data:
        s3.Bucket(bucket).put_object(Key=os.path.basename(file_name), Body=data)


if __name__ == "__main__":
    upload_file()
