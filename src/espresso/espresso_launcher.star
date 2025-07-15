ethereum_package = import_module("github.com/ethpandaops/ethereum-package/main.star")

IMAGE_NAME_ESPRESSO = (
    "ghcr.io/espressosystems/espresso-sequencer/espresso-dev-node:release-colorful-snake"
)
SERVICE_NAME_ESPRESSO = "op-espresso-devnode"

SEQUENCER_PORT_ID = "sequencer"
SEQUENCER_PORT_NUMBER = 24000
BUILDER_PORT_ID = "builder"
BUILDER_PORT_NUMBER = 31003

USED_PORTS = {
    SEQUENCER_PORT_ID: PortSpec(
        number=SEQUENCER_PORT_NUMBER,
        transport_protocol="TCP",
        application_protocol="HTTP",
        wait="5m",
    ),
    BUILDER_PORT_ID: PortSpec(
        number=BUILDER_PORT_NUMBER,
        transport_protocol="TCP",
        application_protocol="HTTP",
        wait="5m",
    ),
}



def launch_espresso(plan, l1_rpc_url, espresso_params):
    env_vars = {
        "ESPRESSO_BUILDER_PORT": str(BUILDER_PORT_NUMBER),
        "ESPRESSO_SEQUENCER_API_PORT": str(SEQUENCER_PORT_NUMBER),
        "ESPRESSO_DEPLOYER_ACCOUNT_INDEX": "0",
        "ESPRESSO_DEV_NODE_PORT": "24001",
        "ESPRESSO_SEQUENCER_ETH_MNEMONIC": ethereum_package.constants.DEFAULT_MNEMONIC,
        "ESPRESSO_SEQUENCER_L1_PROVIDER": l1_rpc_url,
        "ESPRESSO_SEQUENCER_DATABASE_MAX_CONNECTIONS": "25",
        "ESPRESSO_SEQUENCER_STORAGE_PATH": "/data/espresso",
        "ESPRESSO_SEQUENCER_PLONK_VERIFIER_ADDRESS": "0xb4b46bdaa835f8e4b4d8e208b6559cd267851051",
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
