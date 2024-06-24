import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {UniswapMethods} from "../UniswapMethods.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {UserActions} from "../UserActions.sol";

import {Events} from "../Events.sol";

import "../../interfaces/Icapstorage.sol";

library GetUpl {
    function getUpl(State storage state,address user) public view returns (int256 upl) {
        ICapStorage.Position[] memory positions = store.getUserPositions(user);
        for (uint256 j = 0; j < positions.length; j++) {
            IStore.Position memory position = positions[j];
            IStore.Market memory market = store.getMarket(position.market);

            uint256 chainlinkPrice = chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;

            (int256 pnl,) = _getPnL(
                position.market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker
            );

            upl += pnl;
        }

        return upl;
    }
}
    