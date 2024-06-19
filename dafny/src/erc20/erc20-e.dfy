
include "../util/solidity.dfy"


import opened Solidity


class ERC20 {
    var balances: mapping<address, uint>
    var allowance: mapping<address, mapping<address, uint>>
    var supply: uint

    constructor() {
        balances := Map(map[], 0);
        allowance := Map(map[], Map(map[], 0));
        supply := 0;
    }

    method mint(msg: Transaction, dst: address, wad: uint)
    ensures supply == old(supply) + wad
    modifies this`balances, this`supply {
        balances := balances.Set(dst, balances.Get(dst) + wad);
        supply := supply + wad;
    }


    method approve(msg: Transaction, guy: uint, wad: uint)
    returns (r: Result<bool>)
    modifies this`allowance {
        var a := allowance.Get(msg.sender).Set(guy, wad);
        allowance := allowance.Set(msg.sender, a);
        return Ok(true);
    }


    method transferFrom(msg: Transaction, src: uint, dst: address, wad: uint)
    returns (r: Result<bool>)
    modifies this`balances, this`allowance
    requires this.balances.default == 0
    requires src in balances.Keys() && dst in balances.Keys()
    requires msg.value == 0
    ensures r != Revert ==> sum(old(this.balances.Items())) == sum(this.balances.Items()) {
        if balances.Get(src) < wad { return Revert; }

        if src != msg.sender {
            if allowance.Get(src).Get(msg.sender) < wad { return Revert; }
            var a := allowance.Get(src);
            allowance := allowance.Set(src,a.Set(msg.sender, a.Get(msg.sender) -wad));
        }

        // accounting
        balances := balances.Set(src, balances.Get(src) - wad);
        balances := balances.Set(dst, balances.Get(dst) + wad);

        //validate_transfer(old(balances), balances, src, dst, wad);

        r := Result<bool>.Ok(true);

    }


    lemma validate_transfer(prior: mapping<address,uint>, after: mapping<address,uint>, src: address, dst: address, wad: uint)
    requires prior.Get(src) >= wad
    requires after.data[src := 0][dst := 0] == prior.data[src := 0][dst := 0]
    requires {src,dst} <= prior.Keys() && prior.Keys() == after.Keys()
    requires (dst == src) || prior.data[src] - wad == after.data[src]
    requires (dst == src) || prior.data[dst] + wad == after.data[dst]
    requires (dst != src) || after == prior
    ensures sum(prior.Items()) == sum(after.Items()) {
        var b1 := (src, prior.data[src]);
        var b2 := (dst, prior.data[dst]);
        var a1 := (src, after.data[src]);
        var a2 := (dst, after.data[dst]);
        if dst == src {
            // there are cases it will crash
        } else {
            var b_base := prior.Items() - {b1,b2};
            var a_base := after.Items() - {a1,a2};
            // fixme: why assumtion here?
            assume {:axiom} a_base == b_base;
            // base case
            set_as_union(b1,b2);
            set_as_union(a1,a2);
            assert sum({b1,b2}) == sum({a1,a2});
            assert prior.Items() == b_base + {b1,b2};
            assert after.Items() == b_base + {a1,a2};
            union_sum_as_units(b_base, {b1,b2});
            union_sum_as_units(b_base, {a1,a2});
        }
    }

}

