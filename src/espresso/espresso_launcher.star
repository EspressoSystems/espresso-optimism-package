ethereum_package = import_module("github.com/ethpandaops/ethereum-package/main.star")

IMAGE_NAME_ESPRESSO = (
    "ghcr.io/espressosystems/espresso-sequencer/espresso-dev-node:release-goldendoodle"
)
SERVICE_NAME_ESPRESSO = "op-espresso-devnode"

IMAGE_NAME_DAS = "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-batcher:develop"
SERVICE_NAME_ESPRESSO_DAS = "op-espresso-das"

SEQUENCER_PORT_ID = "sequencer"
SEQUENCER_PORT_NUMBER = 24000
BUILDER_PORT_ID = "builder"
BUILDER_PORT_NUMBER = 31003

DAS_PORT_ID = "espresso-das"
DAS_PORT_NUMBER = 3100

USED_PORTS = {
    SEQUENCER_PORT_ID: PortSpec(
        number=SEQUENCER_PORT_NUMBER,
        transport_protocol="TCP",
        application_protocol="HTTP",
        wait="10s",
    ),
    BUILDER_PORT_ID: PortSpec(
        number=BUILDER_PORT_NUMBER,
        transport_protocol="TCP",
        application_protocol="HTTP",
        wait="10s",
    ),
}

USED_PORTS_DAS = {
    DAS_PORT_ID: PortSpec(
        number=DAS_PORT_NUMBER,
        transport_protocol="TCP",
        application_protocol="HTTP",
    ),
}


def launch_espresso(plan, l1_rpc_url, espresso_params):
    env_vars = {
        "ESPRESSO_BUILDER_PORT": str(BUILDER_PORT_NUMBER),
        "ESPRESSO_SEQUENCER_API_PORT": str(SEQUENCER_PORT_NUMBER),
        "ESPRESSO_DEPLOYER_ACCOUNT_INDEX": "0",
        "ESPRESSO_DEV_NODE_PORT": str(SEQUENCER_PORT_NUMBER + 1),
        "ESPRESSO_SEQUENCER_ETH_MNEMONIC": ethereum_package.constants.DEFAULT_MNEMONIC,
        "ESPRESSO_SEQUENCER_L1_PROVIDER": l1_rpc_url,
        "ESPRESSO_SEQUENCER_DATABASE_MAX_CONNECTIONS": "25",
        "ESPRESSO_SEQUENCER_STORAGE_PATH": "/data/espresso",
        "RUST_LOG": "info"
    }

    config = ServiceConfig(
        image=IMAGE_NAME_ESPRESSO,
        ports=USED_PORTS,
        env_vars=env_vars,
    )

    service = plan.add_service(SERVICE_NAME_ESPRESSO, config)
    plan.print(service)

    sequencer_api_url = "http://{}:{}".format(
        service.hostname, service.ports[SEQUENCER_PORT_ID].number
    )

    return sequencer_api_url
