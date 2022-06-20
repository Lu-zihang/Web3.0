import sys

import web3

try:
    from web3 import *
except ImportError:
    sys.exit(0)


class Web3Utils:

    def __init__(self, rpc, **kwargs) -> None:
        self.web3 = Web3(EthereumTesterProvider())
        if kwargs['IPCProvider']:
            setattr(self, 'IPCProvider', kwargs['IPCProvider'])
        if kwargs['HTTPProvider']:
            setattr(self, 'HTTPProvider', kwargs['HTTPProvider'])
        if kwargs['WebsocketProvider']:
            setattr(self, 'WebsocketProvider', kwargs['WebsocketProvider'])
        
        self.load_providers()
        
        
    def get_rpc_address_list(self) -> list[...]:
        return self.web3.eth.accounts
    
    def get_rpc_address(self) -> str:
        return self.web3.eth.accounts[0]
    
    def get_meta_block_infos(self):
        params = {
            block 
        }
        
    
    @property
    def is_connected(self) -> bool:
        return self.web3.isConnected()

    def load_providers(self, rpc:str):
        if "IPCProvider" == rpc:
            if hasattr(self, rpc):
                self.web3.IPCProvider(self.rpc)

        if "HTTPProvider" == rpc:
            if hasattr(self, rpc):
                self.web3.HTTPProvider(self.rpc)

        if "WebsocketProvider" == rpc:
            if hasattr(self, rpc):
                self.web3.WebsocketProvider(self.rpc)


    
    
    
