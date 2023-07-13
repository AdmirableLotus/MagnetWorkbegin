from vyper.interfaces import ERC20
from vyper.interfaces import ERC165
from vyper.interfaces import ERC721

implements: ERC721
implements: ERC165

# Interface for the contract called by safeTransferFrom()
interface ERC721Receiver:
    def onERC721Received(
        operator: address, sender: address, tokenId: uint256, data: Bytes[1024]
    ) -> bytes4: nonpayable


# @dev Emits when ownership of any NFT changes by any mechanism.
event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _tokenId: indexed(uint256)


# @dev This emits when the approved address for an NFT is changed or reaffirmed.
event Approval:
    _owner: indexed(address)
    _approved: indexed(address)
    _tokenId: indexed(uint256)


# @dev This emits when an operator is enabled or disabled for an owner.
event ApprovalForAll:
    _owner: indexed(address)
    _operator: indexed(address)
    _approved: bool


IDENTITY_PRECOMPILE: constant(
    address
) = 0x0000000000000000000000000000000000000004

# Metadata
symbol: public(String[32])
name: public(String[32])

# Permissions
owner: public(address)

# URI
base_uri: public(String[128])
contract_uri: String[128]

# NFT Data
ids_by_owner: HashMap[address, DynArray[uint256, MAX_SUPPLY]]
id_to_index: HashMap[uint256, uint256]
token_count: uint256

owned_tokens: HashMap[
    uint256, address
]  # @dev NFT ID to the address that owns it
token_approvals: HashMap[uint256, address]  # @dev NFT ID to approved address
operator_approvals: HashMap[
    address, HashMap[address, bool]
]  # @dev Owner address to mapping of operator addresses

# @dev Static list of supported ERC165 interface ids
SUPPORTED_INTERFACES: constant(bytes4[5]) = [
    0x01FFC9A7,  # ERC165
    0x80AC58CD,  # ERC721
    0x150B7A02,  # ERC721TokenReceiver
    0x780E9D63,  # ERC721Enumerable
    0x5B5E139F,  # ERC721Metadata
]

# Custom NFT
revealed: public(bool)
default_uri: public(String[150])

MAX_SUPPLY: constant(uint256) = 300
MAX_PREMINT: constant(uint256) = 20
MAX_MINT_PER_TX: constant(uint256) = 3
COST: constant(uint256) = as_wei_value(0.1, "ether")

al_mint_started: public(bool)
al_signer: public(address)
minter: public(address)
al_mint_amount: public(HashMap[address, uint256])


@external
def __init__(preminters: address[MAX_PREMINT]):
    self.symbol = "MAGNET"
    self.name = "The Magent"
    self.owner = msg.sender
    self.contract_uri = "https://example.com/contract_uri"
    self.default_uri = "https://example.com/default_uri"
    self.al_mint_started = False
    self.al_signer = msg.sender
    self.minter = msg.sender

    for i in range(MAX_PREMINT):
        token_id: uint256 = self.token