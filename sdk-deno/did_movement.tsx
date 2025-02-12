/// sdk.tsx is the deno snippet for the interaction with micro_ai_saas table, crud with the table.

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { oakCors } from "https://deno.land/x/cors/mod.ts";

// import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Account, Aptos, AptosConfig, Network } from "npm:@aptos-labs/ts-sdk";

// Add ts sdk
console.log("Hello from DID-Movement-SDK!");

const router = new Router();

// Function to save data as text file
async function saveAsTextFile(fileName: string, data: string): Promise<void> {
  // const payload = await Deno.readFile("./9bfdbf2c-dd87-4028-bb96-4a17f1ecd038.txt");
  // // Convert buffer to string using TextDecoder
  // const payloadString = new TextDecoder().decode(payload);
    const encoder = new TextEncoder();
    const textData = encoder.encode(data);
    await Deno.writeFile(fileName, textData);
}

async function saveAsImageFile(fileName: string, data: string): Promise<void> {
  const image_data = data.split(',')[1];
  // Convert base64 to Uint8Array
  const binary_data = new Uint8Array(atob(image_data).split('').map(char => char.charCodeAt(0)));
  await Deno.writeFile(fileName, binary_data);
}

async function readTextFile(fileName: string): Promise<string> {
    const data = await Deno.readFile(fileName);
    return new TextDecoder().decode(data);
}

// TODO: the bug is here, the aptos is not working.
// const config = new AptosConfig({ network: Network.MAINNET });
// const aptos = new Aptos(config);

// const fund = await aptos.getAccountInfo({ accountAddress: "0x1" });
// console.log(fund);

router
    .get("/", async (context) => {
        context.response.body = "Hello from DID-Movement-SDK!";
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
        // console.log(`private key is: ${acct.privateKey}`);
        const kv = await Deno.openKv();
        const info = {
            priv: acct.privateKey.toString(),
            data_count: 0
        };
        await kv.set(["accts", acct.accountAddress.toString()], info);
        context.response.body = {
            address: acct.accountAddress.toString(),
            // private_key: acct.privateKey.toString()
        };
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
        // TODO: init did for the aptos.
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const type = queryParams.get("type");
        const description = queryParams.get("description");

        const kv = await Deno.openKv();
        
        // Check if DID already exists for this address
        const existing = await kv.get(["accts", "did", addr]);
        console.log(existing);
        if (existing.value) {
            context.response.status = 400;
            context.response.body = "DID already exists for this address";
            return;
        }

        // Set DID only if it doesn't exist
        await kv.set(["accts", "did", addr], {
            type: type,
            description: description
        });

        context.response.body = "Init did successfully";
    })
    .get("/did_register_service", async (context) => {
        // TODO: register new service on aptos.
        const queryParams = context.request.url.searchParams;
        const addr = queryParams.get("addr");
        const description = queryParams.get("description");
        
        const URL = Deno.env.get("URL");
        
        const kv = await Deno.openKv();
        const services = await kv.get(["accts", "did", "services", addr]);
        if (!services.value) {
            await kv.set(["accts", "did", "services", addr], {
                services: [{
                    description: description,
                    // !!REMEMBER TO SET THE URL AFTER DEPLOYED.
                    url: `${URL}/records?addr=${addr}`,
                    expired_at: 0 
                    // 0 means the service is not expired.
                }]
            });
        }
        context.response.body = "register service successfully";
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
