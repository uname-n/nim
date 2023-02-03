from times import now, utc, format
from nimSHA2 import computeSHA256, hex
from strutils import repeat, parseInt

type Block = object
    block_id:int
    data:string
    timestamp:string
    hash:string
    previous_hash:string
    nonce:int
    diff:int

type BlockChain = object
    blocks:seq[Block]
    previous_block:Block
    diff:int

proc build_hash(self:var Block): (string, int) = 
    self.hash = computeSHA256($self).hex
    while self.hash[0..<self.diff] != repeat("0", self.diff):
        inc self.nonce
        self.hash = computeSHA256($self).hex
    return (self.hash, self.nonce)

proc blockchain*(diff: int): BlockChain =
    var x = BlockChain(diff:diff)
    var b = Block(
        data:"genesis-block",
        timestamp:now().utc.format("yyyy-MM-dd-HH-mm-ss-tt-fff-fffffffff"),
        diff:x.diff
    )
    
    discard b.build_hash()
    x.blocks.add(b)
    x.previous_block = x.blocks[0]
    
    return x

proc request*(self: var BlockChain, data:string): Block = 
    var new_block = Block(
        block_id: self.previous_block.block_id,
        data:data,
        timestamp:now().utc.format("yyyy-MM-dd-HH-mm-ss-tt-fff-fffffffff"),
        previous_hash:self.previous_block.hash,
        diff:self.diff
    )
    
    inc new_block.block_id
    discard new_block.build_hash()
    
    self.blocks.add(new_block)
    self.previous_block = new_block
    
    return new_block

when isMainModule:

    var b = blockchain(diff=2)
    
    discard b.request("ABC")
    discard b.request("DEF")
    discard b.request("GHI")
    discard b.request("JKL")
    
    echo b.previous_block