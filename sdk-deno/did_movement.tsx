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
    .get("/acct_gen", async (context) => {
        // TODO: generate a new account.
        const acct: Account = Account.generate();
        console.log("=== Addresses ===\n");
        console.log(`address is: ${acct.accountAddress}`);
        console.log(`private key is: ${acct.privateKey}`);
        context.response.body = {
            address: acct.accountAddress.toString(),
            private_key: acct.privateKey.toString()
        };
    })
    .get("/balance", async (context) => {
        try {
            // Fetch balance from Aptos testnet API
            const response = await fetch(
                "https://api.testnet.aptoslabs.com/v1/accounts/0x1/resource/0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
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
    .get("/did_init", async (context) => {
        // TODO: init did for the aptos.
        context.response.body = "Hello from DID-Movement-SDK!";
    })
    .get("/did_init", async (context) => {
        // TODO: init did for the aptos.
        const queryParams = context.request.url.searchParams;
        const type = queryParams.get("type");
        const description = queryParams.get("description");
        context.response.body = "Hello from DID-Movement-SDK!";
    })
    .get("/did_register_service", async (context) => {
        // TODO: register new service for corr.ai.
        context.response.body = "Hello from DID-Movement-SDK!";
    })
    .get("/record_insert", async (context) => {
        // TODO: insert record based on the did.
        context.response.body = "Hello from DID-Movement-SDK!";
    })
    .get("/records", async (context) => {
        // TODO: get all the records based on the did.
        context.response.body = "Hello from DID-Movement-SDK!";
    })
    .get("/solve_task", async (context) => {
        // TODO: solve task from the system.
        const queryParams = context.request.url.searchParams;
        const task_id = queryParams.get("task_id");
        // Here is the api, get task from the system.
        // curl https://ai-saas.deno.dev/task\?unique_id\=9bfdbf2c-dd87-4028-bb96-4a17f1ecd038
        // [{"id":1,"user":"0x01","prompt":"generate a pic about cat girl","task_type":"img","solution":"This is the solution to the task","solver":"d064239b-c67a-4107-b8b9-de6118472d51","fee":10,"fee_unit":"ldg","tx":"","created_at":"2025-02-08T12:22:06.605268+00:00","solved_at":"2025-02-08T13:37:04.213","signature":null,"unique_id":"9bfdbf2c-dd87-4028-bb96-4a17f1ecd038"}]
        
        // Fetch task from the system
        const taskResponse = await fetch(`https://ai-saas.deno.dev/task?unique_id=${task_id}`);
        if (!taskResponse.ok) {
            context.response.status = 500;
            context.response.body = { error: "Failed to fetch task" };
            return;
        }
        
        const tasks = await taskResponse.json();
        if (!tasks || tasks.length === 0) {
            context.response.status = 404;
            context.response.body = { error: "Task not found" };
            return;
        }
        
        const task = tasks[0];
        
        // Check if task already has a solution
        if (task.solution && task.solution !== "") {
            context.response.status = 400;
            context.response.body = { error: "This task has already been solved" };
            return;
        }

        // curl -X POST https://api.tokentapestry.com/text2img \
        // -H "Content-Type: application/json" \
        // -d '{
        //   "prompt": "dog",
        //   "chain": "sui",
        //   "network": "testnet",
        //   "tx": "your_transaction_hash_here"
        // }'
        const tokenTapestryResponse = await fetch("https://api.tokentapestry.com/text2img", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                prompt: task.prompt,
                chain: "sui",
                network: "testnet",
                tx: "A5CfjvPpSkdiCMz6v3ofNjPvK8RcViAUF2JsqDJb2dqn" // need a tx to transfer more than 0.003 usdc to 0x6b747322a55ff2e3525ed6810efa1b19fbe5d984bfae8afe12b10da65154b446 and has not been used. 
            })
        });

        if (!tokenTapestryResponse.ok) {
            context.response.status = 500;
            context.response.body = { error: "Failed to generate image" };
            return;
        }

        // The response is a json, the image url is in the response.
        const payload = await tokenTapestryResponse.json();  

        const image = payload.image;
        const image_name = `./${task_id}.png`;
        
        // Use the new function to save the file
        await saveAsImageFile(image_name, image);
        
        // Read the agent info from the file
        let agentData;
        try {
            const fileContent = await readTextFile("./img_agent.txt");
            agentData = JSON.parse(fileContent);
        } catch (error) {
            context.response.status = 500;
            context.response.body = { error: "Failed to read agent data" };
            return;
        }

        // Submit the solution to the system
        const submitResponse = await fetch("https://ai-saas.deno.dev/submit_solution", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                unique_id: task_id,
                solution: image,
                solver: agentData.unique_id,  // Use the unique_id from the file instead of agent_info.addr
                solver_type: ["SD"]
            })
        });

        if (!submitResponse.ok) {
            context.response.status = 500;
            context.response.body = { error: "Failed to submit solution" };
            return;
        }

        const submitResult = await submitResponse.json();
        context.response.status = 200;
        context.response.body = { 
            message: "Image generated and solution submitted successfully"        };
    })

const app = new Application();
app.use(oakCors()); // Enable CORS for All Routes
app.use(router.routes());

console.info("CORS-enabled web server listening on port 8000");
await app.listen({ port: 8000 });
