import logging
import time
import boto3

from crhelper import CfnResource

logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')
client = boto3.client('mediaconnect')


@helper.create
def create(event, context):
    logger.info("Got Create")

    flow_arn = ''
    flow_status = ''

    flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port = _get_resource_properties(
        event)

    _create_flow(flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port)

    while flow_status != 'STANDBY':
        response_list_flows = client.list_flows()

        for flow in response_list_flows['Flows']:
            if flow['Name'] == flow_name:
                flow_arn = flow['FlowArn']
                flow_status = flow['Status']

        if flow_status == 'STANDBY':
            response_start_flow = client.start_flow(
                FlowArn=flow_arn
            )
            logger.info(response_start_flow)
        else:
            time.sleep(3)


@helper.update
def update(event, context):
    logger.info("Got Update")

    flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port = _get_resource_properties(
        event)

    _delete(flow_name)

    return _create_flow(flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port)


@helper.delete
def delete(event, context):
    logger.info("Got Delete")

    flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port = _get_resource_properties(
        event)

    return _delete(flow_name)


def handler(event, context):
    helper(event, context)


def _get_resource_properties(event):
    properties = event.get('ResourceProperties', None)

    flow_name = properties.get('FlowName')
    source_name = properties.get('SourceName')
    source_protocol = properties.get('SourceProtocol')
    source_whitelist_cidr = properties.get('SourceWhitelistCidr')
    source_inbound_port = properties.get('SourceInboundPort')

    return flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port


def _create_flow(flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port):
    client.create_flow(
        Name=flow_name,
        # Outputs=[
        #     {
        #         'CidrAllowList': [
        #             'string',
        #         ],
        #         'Description': 'string',
        #         'Destination': 'string',
        #         'Encryption': {
        #             'Algorithm': 'aes128'|'aes192'|'aes256',
        #             'ConstantInitializationVector': 'string',
        #             'DeviceId': 'string',
        #             'KeyType': 'speke'|'static-key',
        #             'Region': 'string',
        #             'ResourceId': 'string',
        #             'RoleArn': 'string',
        #             'SecretArn': 'string',
        #             'Url': 'string'
        #         },
        #         'MaxLatency': 123,
        #         'Name': 'string',
        #         'Port': 123,
        #         'Protocol': 'zixi-push'|'rtp-fec'|'rtp'|'zixi-pull'|'rist',
        #         'RemoteId': 'string',
        #         'SmoothingLatency': 123,
        #         'StreamId': 'string',
        #         'VpcInterfaceAttachment': {
        #             'VpcInterfaceName': 'string'
        #         }
        #     },
        # ],
        Source={
            'IngestPort': int(source_inbound_port),
            'Name': source_name,
            'Protocol': source_protocol,
            'WhitelistCidr': source_whitelist_cidr
        }
    )


def _delete(flow_name):
    flow_arn = ''
    flow_status = ''

    while flow_status != 'STANDBY':
        response_list_flows = client.list_flows()

        for flow in response_list_flows['Flows']:
            if flow['Name'] == flow_name:
                flow_arn = flow['FlowArn']
                flow_status = flow['Status']

        if flow_status == 'STANDBY':
            response_delete_flow = client.delete_flow(
                FlowArn=flow_arn
            )
            logger.info(response_delete_flow)

        elif flow_status == 'ACTIVE':
            client.stop_flow(
                FlowArn=flow_arn
            )
        else:
            time.sleep(3)
