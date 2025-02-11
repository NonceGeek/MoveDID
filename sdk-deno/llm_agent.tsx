// TODO: like the img_agent.tsx, implement the llm_agent.tsx for the llm task.

import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { oakCors } from "https://deno.land/x/cors/mod.ts";

console.log("Hello from AI SaaSSDK!");

const router = new Router();

const agent_info = {
    addr: "0xac79f707686c2f0d924930dce530c1577fdb69404172e459d1d437e96306de3f", // Replace with actual address
    owner_addr: "0x603142bcc9864820e87be3176403e48208705808b05743bd61dacba2c8b28070",
    type: "llm",
    chat_url: "",
    source_url: "https://github.com/NonceGeek/tai-shang-micro-ai-saas/blob/main/agents/llm_agent.tsx",
    description: "This is a LLM agent based on Atoma, and I'm good at SUI smart contract!"
}

// Function to save data as text file
async function saveAsTextFile(fileName: string, data: string): Promise<void> {
    const encoder = new TextEncoder();
    const textData = encoder.encode(data);
    await Deno.writeFile(fileName, textData);
}

async function readTextFile(fileName: string): Promise<string> {
    const data = await Deno.readFile(fileName);
    return new TextDecoder().decode(data);
}

router
    .get("/", async (context) => {
        context.response.body = "Hello from llm_agent!";
    })
    .get("/register", async (context) => {
        // Register agent to the system before start working
        const registerResponse = await fetch("https://ai-saas.deno.dev/add_agent", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(agent_info)
        });

        if (!registerResponse.ok) {
            context.response.status = 500;
            context.response.body = { error: "Failed to register agent" };
            return;
        }

        const result = await registerResponse.json();
        if (result && result.length > 0) {
            const fileName = `./llm_agent.txt`;
            await saveAsTextFile(fileName, JSON.stringify(result[0], null, 2));
        }

        context.response.status = 200;
        context.response.body = { 
            message: "Agent registered successfully",
            data: result
        };
    })
    .get("/solve_task", async (context) => {
        const queryParams = context.request.url.searchParams;
        const task_id = queryParams.get("task_id");
        
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
        
        if (task.solution && task.solution !== "") {
            context.response.status = 400;
            context.response.body = { error: "This task has already been solved" };
            return;
        }

        // Get API key from environment variable
        const apiKey = Deno.env.get("ATOMA_API_KEY");
        if (!apiKey) {
            context.response.status = 500;
            context.response.body = { error: "ATOMA_API_KEY not found in environment variables" };
            return;
        }

        // Call Atoma API
        const atomaResponse = await fetch("https://api.atoma.network/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${apiKey}`
            },
            body: JSON.stringify({
                stream: false, // Changed to false for simpler handling
                // optional model: "meta-llama/Llama-3.3-70B-Instruct"
                model: "deepseek-ai/DeepSeek-R1",
                messages: [{
                    role: "user",
                    content: task.prompt // Use the task description as the prompt
                }],
                max_tokens: 128
            })
        });

        if (!atomaResponse.ok) {
            context.response.status = 500;
            context.response.body = { error: "Failed to get response from Atoma API" };
            return;
        }

        const atomaResult = await atomaResponse.json();

        // Response format: https://docs.atoma.network/cloud-api-reference/chat/create-chat-completion
        //         {
        // "choices": [
        //     {
        //       "finish_reason": "stop",
        //       "index": 0,
        //       "logprobs": "<any>",
        //       "message": {
        //         "content": "Hello! How can you help me today?",
        //         "name": "john_doe",
        //         "role": "user"
        //       }
        //     }
        //   ],
        //   "created": 1677652288,
        //   "id": "chatcmpl-123",
        //   "model": "meta-llama/Llama-3.3-70B-Instruct",
        //   "system_fingerprint": "fp_44709d6fcb",
        //   "usage": null
        // }
        const solution = atomaResult.choices[0].message.content;
        console.log(solution);
        // Read the agent info from the file
        let agentData;
        try {
            const fileContent = await readTextFile("./llm_agent.txt");
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
                solution: solution,
                solver: agentData.unique_id,
                solver_type: ["Atoma"]
            })
        });

        if (!submitResponse.ok) {
            context.response.status = 500;
            context.response.body = { error: "Failed to submit solution" };
            return;
        }

        context.response.status = 200;
        context.response.body = { 
            message: "LLM response generated and solution submitted successfully"
        };
    });

const app = new Application();
app.use(oakCors()); // Enable CORS for All Routes
app.use(router.routes());

console.info("CORS-enabled web server listening on port 8000");
await app.listen({ port: 8000 });
