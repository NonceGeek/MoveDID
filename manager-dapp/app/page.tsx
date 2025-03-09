/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable react-hooks/exhaustive-deps */

"use client";

import { useWallet } from "@razorlabs/razorkit";
import { useState, useEffect } from "react";
import {
  InputEntryFunctionData,
  InputViewFunctionData,
  Aptos,
  AptosConfig,
} from "@aptos-labs/ts-sdk";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Header } from "@/components/header";
import { useToast } from "@/hooks/use-toast";

const DID_TYPES = [
  { value: "0", label: "Human" },
  { value: "1", label: "Organization" },
  { value: "2", label: "AI Agent" },
  { value: "3", label: "Smart Contract" },
];

const MODULE_ADDRESS = process.env.NEXT_PUBLIC_SMART_CONTRACT || "0x61b96051f553d767d7e6dfcc04b04c28d793c8af3d07d3a43b4e2f8f4ca04c9f";

// Use environment variable with fallback for the fullnode URL
const FULLNODE_URL = process.env.NEXT_PUBLIC_APTOS_FULLNODE_URL || "https://aptos.testnet.bardock.movementlabs.xyz/v1";
console.log("FULLNODE_URL:", FULLNODE_URL);
const config = new AptosConfig({
  fullnode: FULLNODE_URL,
});
const client = new Aptos(config);

// 定义标题样式变体
const TITLE_STYLES = [
  {
    title: "pixel-text-rainbow",
    link: "pixel-link-bounce",
    color: "text-[var(--pixel-accent)]"
  },
  {
    title: "pixel-text-glitch",
    link: "pixel-link-shake",
    color: "text-[#ff71ce]" // 霓虹粉
  },
  {
    title: "pixel-text-pulse",
    link: "pixel-link-spin",
    color: "text-[#01cdfe]" // 霓虹蓝
  },
  {
    title: "pixel-text-wave",
    link: "pixel-link-blink",
    color: "text-[#05ffa1]" // 霓虹绿
  },
  {
    title: "pixel-text-rainbow",
    link: "pixel-link-bounce",
    color: "text-[#b967ff]" // 霓虹紫
  },
  {
    title: "pixel-text-glitch",
    link: "pixel-link-shake",
    color: "text-[#fffb96]" // 霓虹黄
  }
];

export default function Home() {
  const { account, connected, signAndSubmitTransaction } = useWallet();
  const [didType, setDidType] = useState<string>("");
  const [description, setDescription] = useState<string>("");
  const [didInfo, setDidInfo] = useState<{
    type: string;
    description: string;
  } | null>(null);
  const [loading, setLoading] = useState(false);
  const [fetchingInfo, setFetchingInfo] = useState(false);
  const [styleVariant, setStyleVariant] = useState(TITLE_STYLES[0]);
  const { success, error } = useToast();

  const [address, setAddress] = useState<string | null>(null);

  useEffect(() => {
    setStyleVariant(TITLE_STYLES[Math.floor(Math.random() * TITLE_STYLES.length)]);
  }, []);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const addrParam = params.get('addr');
    setAddress(addrParam);
  }, []);

  useEffect(() => {
    if (address) {
      setDidInfo(null);
      setFetchingInfo(true);
      fetchDidInfo(address).finally(() => {
        setFetchingInfo(false);
      });
    } else if (connected && account?.address) {
      setDidInfo(null);
      setFetchingInfo(true);
      fetchDidInfo(account.address).finally(() => {
        setFetchingInfo(false);
      });
    } else {
      setDidInfo(null);
    }
  }, [connected, account, address]);

  const fetchDidInfo = async (addressToFetch: string) => {
    try {
      // 调用合约获取DID信息
      const type = await getType(addressToFetch);
      const desc = await getDescription(addressToFetch);
      if (type !== null && desc) {
        setDidInfo({ type: DID_TYPES[type].label, description: desc });
      } else {
        setDidInfo(null);
      }
    } catch (error) {
      console.error("Error fetching DID info:", error);
    }
  };

  const getType = async (address: string): Promise<number | null> => {
    if (!address) return null;
    
    try {
      const payload: InputViewFunctionData = {
        function: `${MODULE_ADDRESS}::addr_aggregator::get_type`,
        typeArguments: [],
        functionArguments: [address],
      };
      
      const response = await client.view({ payload });
      return Number(response[0]);
    } catch (error) {
      console.error("Error fetching type:", error);
      return null;
    }
  };

  const getDescription = async (address: string): Promise<string | null> => {
    if (!address) return null;
    
    try {
      const payload: InputViewFunctionData = {
        function: `${MODULE_ADDRESS}::addr_aggregator::get_description`,
        typeArguments: [],
        functionArguments: [address],
      };
      
      const response = await client.view({ payload });
      return response[0] as string;
    } catch (error) {
      console.error("Error fetching description:", error);
      return null;
    }
  };

  const handleCreateDid = async () => {
    if (!connected || !account?.address) {
      error("Please connect wallet first");
      return;
    }

    setLoading(true);
    try {
      const payload: InputEntryFunctionData = {
        function: `${MODULE_ADDRESS}::init::init`,
        typeArguments: [],
        functionArguments: [parseInt(didType), description],
      };

      const response = await signAndSubmitTransaction({ payload }) as unknown as { args: { hash: string } };
      console.log("Transaction hash:", response);
      
      // 等待交易确认
      try {
        const pendingTransaction = await client.waitForTransaction({
          transactionHash: response.args.hash ,
        });
        console.log("Transaction confirmed:", pendingTransaction);
        
        // 交易确认后再获取DID信息
        await fetchDidInfo(account.address);
        success("DID created successfully!");
      } catch (err) {
        console.error("Error waiting for transaction:", err);
        error("Transaction failed to confirm. Please try again.");
      }
    } catch (err) {
      console.error("Error creating DID:", err);
      error("Failed to create DID. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen pixel-font bg-[var(--pixel-background)] text-[var(--pixel-text)]">
      <Header />
      <div className="container mx-auto px-4 py-8">
        <div className="pt-20">
          <div className="text-center mb-8">
            <h1 className={`text-3xl mb-4 pixel-text ${styleVariant.title} ${styleVariant.color}`}>
              Generate the Identity on the Movement!
            </h1>
            <a
              href="https://x.com/intent/follow?screen_name=root_mud"
              target="_blank"
              rel="noopener noreferrer"
              className={`inline-block text-sm transition-colors underline pixel-text ${styleVariant.link} ${styleVariant.color}`}
            >
              follow us
            </a>
          </div>
          
          {fetchingInfo ? (
            <div className="max-w-2xl mx-auto bg-[var(--pixel-card)] p-6 rounded-lg pixel-border">
              <h2 className="text-xl mb-4 pixel-text text-center">Loading DID Information...</h2>
              <div className="pixel-loading"></div>
            </div>
          ) : (
            <div className="space-y-6">
              {didInfo && (
                <div className="max-w-2xl mx-auto bg-[var(--pixel-card)] p-6 rounded-lg pixel-border">
                  <center><h2 className="text-xl mb-4 pixel-text">Your DID Information</h2></center>
                  <center><p className="mb-2"><b>TYPE: </b><br></br> {didInfo.type}</p></center>
                  <center><p><b>DESCRIPTION: </b><br></br> {didInfo.description}</p></center>
                </div>
              )}
            </div>
            )}
          

          {!connected && (
            <div className="max-w-2xl mx-auto">
              <div className="text-center mb-6">
                <p className="mb-4 pixel-text text-[var(--pixel-accent)]">
                  <br></br>
                  Please Connect your wallet to create DID
                </p>
              </div>
            </div>
          )}

          {connected && !didInfo && (
            <div className="max-w-2xl mx-auto">
              <div className="bg-[var(--pixel-card)] p-6 rounded-lg pixel-border">
                <center><h2 className="text-xl mb-4 pixel-text">Create DID</h2></center>
                <div className="space-y-4">
                  <Select
                    value={didType}
                    onValueChange={setDidType}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select DID Type" />
                    </SelectTrigger>
                    <SelectContent>
                      {DID_TYPES.map((type) => (
                        <SelectItem key={type.value} value={type.value}>
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>

                  <Input
                    placeholder="Enter description"
                    className="pixel-input"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />

                  <Button
                    className="w-full pixel-button"
                    onClick={handleCreateDid}
                    disabled={!didType || !description || loading}
                  >
                    {loading ? "Creating..." : "Create DID"}
                  </Button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
