/// sdk.tsx is the deno snippet for the interaction with micro_ai_saas table, crud with the table.

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { oakCors } from "https://deno.land/x/cors/mod.ts";

// import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Account, Aptos, AptosConfig, Network, Ed25519PrivateKey } from "npm:@aptos-labs/ts-sdk";
import { Buffer } from "node:buffer";

// Add ts sdk
console.log("Hello from DID-Movement-SDK!");

const router = new Router();

router
    .get("/", async (context) => {
        context.response.body = "Hello from DID-Movement-SDK!";
    })
    .get("/docs", async (context) => {
        const docs = `# 1. Root endpoint
curl https://did-movement.deno.dev/

# 2. Network Set
curl https://did-movement.deno.dev/network_set

# 3. Network Info
curl https://did-movement.deno.dev/network_info

# 4. Generate Account
curl https://did-movement.deno.dev/acct_gen

# 5. Get Account Info (replace with actual Aptos address)
curl "https://did-movement.deno.dev/acct_info?addr=0x123...abc"

# 6. Get Balance (replace with actual Aptos address)
curl "https://did-movement.deno.dev/balance?addr=0x1"

# 7. Get Resources (replace with actual Aptos address)
curl "https://did-movement.deno.dev/resources?addr=0x123...abc"

# 8. Initialize DID
curl "https://did-movement.deno.dev/did_init?addr=0x123...abc&type=2&description=my_identity"

# 9. Register DID Service
curl "https://did-movement.deno.dev/did_register_service?addr=0x123...abc&description=my_service"

# 10. Insert Record
curl "https://did-movement.deno.dev/record_insert?addr=0x123...abc&record=some_record_data"

# 11. Get Records
curl "https://did-movement.deno.dev/records?addr=0x123...abc"`;
        context.response.body = docs;
    })
    .get("/network_set", async (context) => {
        // TODO: set the network for the deno sdk.
        context.response.body = "network set successfully";
    })
    .get("/network_info", async (context) => {
        // get the network info for the deno sdk.
        const network = Deno.env.get("NETWORK");
        const url = Deno.env.get("URL");
        console.log(network, url);
        context.response.body = network;
    })
    .get("/acct_gen", async (context) => {
        // generate a new account.
        const acct: Account = Account.generate();
        console.log("=== Addresses ===\n");
        console.log(`address is: ${acct.accountAddress}`);
        console.log(`private key is: ${acct.privateKey}`);
        const kv = await Deno.openKv();
        const info = {
            // 确保存储的私钥带有 0x 前缀
            priv: acct.privateKey.toString().startsWith('0x') 
                ? acct.privateKey.toString() 
                : `0x${acct.privateKey.toString()}`,
            data_count: 0
        };
        await kv.set(["accts", acct.accountAddress.toString()], info);
        context.response.body = {
            address: acct.accountAddress.toString(),
        };
    })
    .get("/acct_check", async (context) => {
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const kv = await Deno.openKv();
        // 从KV中获取私钥
        const acctInfo = await kv.get(["accts", addr]);
        if (!acctInfo.value?.priv) {
            context.response.status = 400;
            context.response.body = "Account not found";
            return;
        }

        console.log(acctInfo.value.priv);
        const acct: Account = Account.generate();

        // 创建Account实例
        const account = Account.fromPrivateKey({
            privateKey: acct.privateKey
        });

        console.log(account);
        context.response.body = account;
    })
    .get("/acct_info", async (context) => {
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const kv = await Deno.openKv();
        const info = await kv.get(["accts", addr]);
        const did = await kv.get(["accts", "did", addr]);
        const services = await kv.get(["accts", "did", "services", addr]);
        
        // Create a new object without the private key
        const safeInfo = info.value ? {
            data_count: info.value.data_count
        } : null;
        
        context.response.body = {
            "info": safeInfo,
            "did": did.value,
            "services": services.value,
            "explorer": `https://explorer.aptoslabs.com/account/${addr}?network=testnet`
        };
    })
    .get("/balance", async (context) => {
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        try {
            // Fetch balance from Aptos testnet API
            const response = await fetch(
                `https://api.testnet.aptoslabs.com/v1/accounts/${addr}/resource/0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>`
            );

            if (!response.ok) {
                throw new Error('Failed to fetch balance');
            }

            const data = await response.json();
            
            // Extract balance value and convert from octas to APT (1 APT = 100000000 octas)
            const balanceInOctas = BigInt(data.data.coin.value);
            const balanceInApt = Number(balanceInOctas) / 100000000;

            context.response.body = {
                balance_octas: data.data.coin.value,
                balance_apt: balanceInApt,
                frozen: data.data.frozen
            };
        } catch (error) {
            context.response.status = 500;
            context.response.body = {
                error: "Failed to fetch balance",
                details: error.message
            };
        }
    })
    .get("/resources", async (context) => {
        // get all the resources for the aptos.
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        // curl --request GET \--url https://api.testnet.aptoslabs.com/v1/accounts/0x88fbd33f54e1126269769780feb24480428179f552e2313fbe571b72e62a1ca1/resources
        const response = await fetch(`https://api.testnet.aptoslabs.com/v1/accounts/${addr}/resources`);
        const data = await response.json();
        context.response.body = data;
    })
    .get("/did_init", async (context) => {
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const type = queryParams.get("type");
        const description = queryParams.get("description");

        if (!addr || !type || !description) {
            context.response.status = 400;
            context.response.body = "Missing required parameters";
            return;
        }

        try {
            const kv = await Deno.openKv();
            
            // 检查DID是否已存在
            const existing = await kv.get(["accts", "did", addr]);
            if (existing.value) {
                context.response.status = 400;
                context.response.body = "DID already exists for this address";
                return;
            }

            // 从KV中获取私钥
            const acctInfo = await kv.get(["accts", addr]);
            if (!acctInfo.value?.priv) {
                context.response.status = 400;
                context.response.body = "Account not found";
                return;
            }

            try {
                console.log(acctInfo);
                const privateKeyHex = acctInfo.value.priv.replace('0x', '');
                const privateKey = new Ed25519PrivateKey(privateKeyHex);
                const account = Account.fromPrivateKey({ privateKey });
                console.log(account);

                // 获取账户序列号
                const sequenceNumber = await getAccountSequenceNumber(account.accountAddress.toString());
                
                const config = new AptosConfig({ network: Network.TESTNET });
                const aptos = new Aptos(config);
                const APTOS_COIN = "0x1::aptos_coin::AptosCoin";
                const simpleTransaction = await aptos.transaction.build.simple({
                    sender: account,
                    data: {
                      function: "0x1::coin::transfer",
                      typeArguments: [APTOS_COIN],
                      functionArguments: ["0x1", 1],
                    },
                  });
                console.log(simpleTransaction);
                // https://github.com/aptos-labs/aptos-ts-sdk/blob/main/examples/typescript/external_signing.ts
                
                // 手动构建交易
                const transaction = {
                    sender: account.accountAddress.toString(),
                    sequence_number: sequenceNumber,
                    max_gas_amount: "2000",
                    gas_unit_price: "100",
                    expiration_timestamp_secs: (Math.floor(Date.now() / 1000) + 600).toString(),
                    payload: {
                        type: "entry_function_payload",
                        function: "0x1::aptos_coin::transfer",
                        // function: "0xc71124a51e0d63cfc6eb04e690c39a4ea36774ed4df77c00f7cbcbc9d0505b2c::did::init",
                        type_arguments: [],
                        arguments: [1]
                    }
                };

                // 序列化交易
                const serializedTx = Buffer.from(JSON.stringify(transaction)).toString('hex');
                
                // 签名序列化后的交易
                const signature = account.sign(serializedTx);
                
                const signedTxn = {
                    ...transaction,
                    signature: {
                        type: "ed25519_signature",
                        public_key: account.publicKey.toString(),
                        signature: signature.toString()
                    }
                };

                // 提交交易
                const response = await fetch("https://fullnode.testnet.aptoslabs.com/v1/transactions", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify(signedTxn)
                });

                if (!response.ok) {
                    throw new Error(`Transaction submission failed: ${await response.text()}`);
                }

                const txnData = await response.json();

                // 等待交易完成
                const txnHash = txnData.hash;
                let txnResult;
                for (let i = 0; i < 10; i++) {
                    const statusResponse = await fetch(
                        `https://fullnode.testnet.aptoslabs.com/v1/transactions/by_hash/${txnHash}`
                    );
                    txnResult = await statusResponse.json();
                    if (txnResult.type === "user_transaction" && txnResult.success) {
                        break;
                    }
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }

                if (!txnResult?.success) {
                    throw new Error("Transaction failed or timeout");
                }

                // 保存DID信息到KV
                await kv.set(["accts", "did", addr], {
                    type: type,
                    description: description,
                    hash: txnResult.hash,
                    version: txnResult.version
                });

                context.response.body = {
                    message: "DID initialized successfully",
                    hash: txnResult.hash,
                    version: txnResult.version
                };

            } catch (error) {
                throw new Error(`Transaction failed: ${error.message}`);
            }

        } catch (error) {
            context.response.status = 500;
            context.response.body = {
                error: "Failed to initialize DID",
                details: error instanceof Error ? error.message : String(error)
            };
        }
    })
    .get("/did_register_service", async (context) => {
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        
        if (!addr || !name) {
            context.response.status = 400;
            context.response.body = "Missing required parameters";
            return;
        }

        try {
            const URL = Deno.env.get("URL");
            const serviceUrl = `${URL}/records?addr=${addr}`;
            const kv = await Deno.openKv();
            const name = "corr.ai";
            const description = "the ai-agent for crypto trading.";
            // 构建交易payload
            const payload = {
                function: "0xc71124a51e0d63cfc6eb04e690c39a4ea36774ed4df77c00f7cbcbc9d0505b2c::service_aggregator::add_service",
                type_arguments: [],
                arguments: [
                    name,
                    description,
                    serviceUrl,
                    "", //verification_url
                    "", // spec_fields
                    "0"  // expired_at
                ]
            };

            // 从KV中获取私钥
            const acctInfo = await kv.get(["accts", addr]);
            if (!acctInfo.value?.priv) {
                context.response.status = 400;
                context.response.body = "Account not found";
                return;
            }

            // 创建Account实例
            const account = Account.fromPrivateKey({
                privateKey: acctInfo.value.priv
            });

            // 提交交易
            const response = await fetch("https://fullnode.testnet.aptoslabs.com/v1/transactions", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    sender: account.accountAddress.toString(),
                    sequence_number: await getAccountSequenceNumber(account.accountAddress.toString()),
                    max_gas_amount: "2000",
                    gas_unit_price: "100",
                    expiration_timestamp_secs: (Math.floor(Date.now() / 1000) + 600).toString(),
                    payload: payload
                })
            });

            if (!response.ok) {
                throw new Error(`Transaction submission failed: ${await response.text()}`);
            }

            const txnData = await response.json();

            // 等待交易完成
            const txnHash = txnData.hash;
            let txnResult;
            for (let i = 0; i < 10; i++) {
                const statusResponse = await fetch(
                    `https://fullnode.testnet.aptoslabs.com/v1/transactions/by_hash/${txnHash}`
                );
                txnResult = await statusResponse.json();
                if (txnResult.type === "user_transaction" && txnResult.success) {
                    break;
                }
                await new Promise(resolve => setTimeout(resolve, 1000));
            }

            if (!txnResult?.success) {
                throw new Error("Transaction failed or timeout");
            }

            // 交易成功后，更新KV中的服务信息
            const services = await kv.get(["accts", "did", "services", addr]);
            const newService = {
                name: name,
                description: description,
                url: serviceUrl,
                verification_url: "",
                spec_fields: "",
                expired_at: 0,
                hash: txnResult.hash,
                version: txnResult.version
            };

            if (!services.value) {
                await kv.set(["accts", "did", "services", addr], {
                    services: [newService]
                });
            } else {
                services.value.services.push(newService);
                await kv.set(["accts", "did", "services", addr], services.value);
            }

            context.response.body = {
                message: "Service registered successfully",
                hash: txnResult.hash,
                version: txnResult.version
            };

        } catch (error) {
            context.response.status = 500;
            context.response.body = {
                error: "Failed to register service",
                details: error instanceof Error ? error.message : String(error)
            };
        }
    })
    .get("/record_insert", async (context) => {
        // insert record based on the did.
        const kv = await Deno.openKv();
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const record = queryParams.get("record");
        const info = await kv.get(["accts", addr]);
        console.log(info.value.data_count);
        await kv.set(["records", addr, info.value.data_count], record);
        await kv.set(["accts", addr], {
            data_count: info.value.data_count + 1
        });
        context.response.body = {
            message: "Record inserted successfully"
        };
    })
    .get("/records", async (context) => {
        // get all the records based on the did.
        const kv = await Deno.openKv();
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const result = kv.list({ prefix: ["records", addr] });
        console.log(result);
        context.response.body = result;
    })

const app = new Application();
app.use(oakCors()); // Enable CORS for All Routes
app.use(router.routes());

console.info("CORS-enabled web server listening on port 8000");
await app.listen({ port: 8000 });

async function getAccountSequenceNumber(address: string): Promise<string> {
    const response = await fetch(
        `https://fullnode.testnet.aptoslabs.com/v1/accounts/${address}`
    );
    if (!response.ok) {
        throw new Error("Failed to fetch account sequence number");
    }
    const accountData = await response.json();
    return accountData.sequence_number;
}
