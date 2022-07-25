pragma solidity =0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';



// SHIB 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
// DOGE 0xf8e81D47203A594245E36C48e151709F0C19fBe8
// PAIR 0x16cB5a93396A144425c442fC934427Ea4F495687
contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;
    
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    // @param `_feeToSetter` 费用接收者
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    // @dev {allPairsLength} 返回交易所中交易对的数量
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }


    // @dev 通过{createPair}函数创建基于两个代币间的交易对
    // 此函数主要功能是为两个代币间创建一个交易对
    // 此函数最突出的就是调用`create2` 操作码来创建pair合约 
    //
    // @param `tokenA`  代币A，例如DogeCoin
    // @param `tokenB`  代币B，例如shibaCoin 
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        //不允许两个token相同
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        
        // `token0` 与 `token1` 分别为A或B
        // 通过三元运算符来分析两个地址不能相同以及为零地址
        // 其中 `tokenA` 小于 `tokenB` 则token0分配tokenA，token1分配tokenB, 反之亦然
        // 比较疑惑的是上面和下面已经做了判断，这一步的代币地址分配可能没这么重要？
        
        // 疑惑解决：默认小的地址作为token0, 区分交易对。例如： A：B  || B：A
        // see {UniswapV2Pair}  if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out)
        // 得到相应的验证
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        // token0 不能为零地址
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');

        // 资金池不能重复创建
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        
        // 获取UniswapV2Pair的合约字节码的内存字节数组,用于构建创建pair合约的参数
        bytes memory bytecode = type(UniswapV2Pair).creationCode;

        // 将token0, token1进行联系
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            // 创建pair交易池合约
            // 等同于new, 使用create2、create都是部署合约的其他opera方式
            // 使用create2区别于new, 即不依赖于不是地址的当前状态
            // 无论当前合约环境如何更改，被创建的合约地址都不会发生改变
            // （0）参数表示发送新合约的wei数量为msg.value，指定为 0
            // 操作的位置在bytecode的下一个空闲内存
            // 加载bytecode的内存位置
            // `salt`作为计算中的随机“盐”
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        // 调用IUniswapV2Pair接口，初始化token0, token1
        IUniswapV2Pair(pair).initialize(token0, token1);
        // getPair中存储映射关系
        getPair[token0][token1] = pair;
        // getPair中存储映射关系
        getPair[token1][token0] = pair; // populate mapping in the reverse direction

        // 将交易对放进总交易对数组中
        allPairs.push(pair);

        // 响应事件 {PairCreated}
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    // @dev {setFeeTo} 设置费用接收者
    // @param `_feeTo` 接收费用的地址
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
