## Quick Scripts

```
starcoin% dev deploy [blob path] -s [deployer acct] -b
starcoin% account execute-function --function [deployer acct]::AddrAggregatorV2::init_addr_aggregator -s [caller addr] -b
starcoin% execute-function --function 0x1168e88ffc5cec53b398b42d61885bbb::AddrAggregatorV4::script_add_addr_unverified --arg b"0x73c7448760517E3E6e416b2c130E3c6dB2026A1d" --arg b"ethereum" --arg b"theAcctToDevelopSth" -s 0x1168e88ffc5cec53b398b42d61885bbb -b
state get resource 0x1168e88ffc5cec53b398b42d61885bbb 0x1168e88ffc5cec53b398b42d61885bbb::AddrAggregatorV4::AddrAggregator
```