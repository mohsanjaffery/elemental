import logging
import boto3

from crhelper import CfnResource

logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')
client = boto3.client('mediaconnect')


@helper.create
def create(event, context):
    logger.info("Got Create")
    pass


@helper.update
def update(event, context):
    logger.info("Got Update")
    pass


@helper.delete
def delete(event, context):
    logger.info("Got Delete")
    pass


def handler(event, context):
    helper(event, context)
