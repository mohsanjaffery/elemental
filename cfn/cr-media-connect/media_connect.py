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

    flow_status = ''
    flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port, output_name, output_protocol, output_destination, output_port = _get_resource_properties(
        event)

    _create_flow(flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port, output_name,
                 output_protocol, output_destination, output_port)

    while flow_status != 'STANDBY':
        flow_arn, flow_status = _list_flow_arn_and_status(flow_name)
        if flow_status == 'STANDBY':
            _start_flow(flow_arn)
        else:
            time.sleep(5)

    return helper.PhysicalResourceId


@helper.update
def update(event, context):
    logger.info("Got Update")

    flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port, output_name, output_protocol, output_destination, output_port = _get_resource_properties(
        event)

    flow_arn, flow_status = _list_flow_arn_and_status(flow_name)

    output_arn, source_arn = _get_source_and_outputs_arn(flow_arn)

    _update_flow_source(flow_arn, source_inbound_port, source_protocol, source_arn, source_whitelist_cidr)

    _update_flow_output(flow_arn, output_arn, output_protocol, output_destination, output_port)


@helper.delete
def delete(event, context):
    logger.info("Got Delete")

    flow_status = ''
    flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port, output_name, output_protocol, output_destination, output_port = _get_resource_properties(
        event)

    while flow_status != 'STANDBY':
        flow_arn, flow_status = _list_flow_arn_and_status(flow_name)
        if flow_status == 'STANDBY':
            _delete_flow(flow_arn)
        elif flow_status == 'ACTIVE':
            _stop_flow(flow_arn)
            time.sleep(5)
        else:
            time.sleep(5)


def handler(event, context):
    helper(event, context)


def _get_resource_properties(event):
    properties = event.get('ResourceProperties', None)

    flow_name = properties.get('FlowName')
    source_name = properties.get('SourceName')
    source_protocol = properties.get('SourceProtocol')
    source_whitelist_cidr = properties.get('SourceWhitelistCidr')
    source_inbound_port = properties.get('SourceInboundPort')
    output_name = properties.get('OutputName')
    output_protocol = properties.get('OutputProtocol')
    output_destination = properties.get('OutputDestination')
    output_port = properties.get('OutputPort')

    return flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port, output_name, output_protocol, output_destination, output_port


def _create_flow(flow_name, source_name, source_protocol, source_whitelist_cidr, source_inbound_port, output_name,
                 output_protocol, output_destination, output_port):
    client.create_flow(
        Name=flow_name,
        Outputs=[
            {
                'Name': output_name,
                'Destination': output_destination,
                'Port': int(output_port),
                'Protocol': output_protocol,
            }
        ],
        Source={
            'IngestPort': int(source_inbound_port),
            'Name': source_name,
            'Protocol': source_protocol,
            'WhitelistCidr': source_whitelist_cidr
        }
    )


def _delete_flow(flow_arn):
    client.delete_flow(
        FlowArn=flow_arn
    )


def _get_source_and_outputs_arn(flow_arn):
    output_arn = ''
    source_arn = ''

    response_describe_flow = client.describe_flow(
        FlowArn=flow_arn
    )

    for output in response_describe_flow['Flow']['Outputs']:
        output_arn = output['OutputArn']

    for source in response_describe_flow['Flow']['Sources']:
        source_arn = source['SourceArn']

    return output_arn, source_arn


def _list_flow_arn_and_status(flow_name):
    flow_arn = ''
    flow_status = ''

    response_list_flows = client.list_flows()

    for flow in response_list_flows['Flows']:
        if flow['Name'] == flow_name:
            flow_arn = flow['FlowArn']
            flow_status = flow['Status']

    return flow_arn, flow_status


def _start_flow(flow_arn):
    client.start_flow(
        FlowArn=flow_arn
    )


def _stop_flow(flow_arn):
    client.stop_flow(
        FlowArn=flow_arn
    )


def _update_flow_output(flow_arn, output_arn, output_protocol, output_destination, output_port):
    client.update_flow_output(
        Destination=output_destination,
        FlowArn=flow_arn,
        OutputArn=output_arn,
        Port=int(output_port),
        Protocol=output_protocol
    )


def _update_flow_source(flow_arn, source_inbound_port, source_protocol, source_arn, source_whitelist_cidr):
    client.update_flow_source(
        FlowArn=flow_arn,
        IngestPort=int(source_inbound_port),
        Protocol=source_protocol,
        SourceArn=source_arn,
        WhitelistCidr=source_whitelist_cidr
    )
