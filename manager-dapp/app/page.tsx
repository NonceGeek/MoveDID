/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable react-hooks/exhaustive-deps */

"use client";

import { useAptosWallet } from "@razorlabs/wallet-kit";
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
  SelectWrapper,
} from "@/components/ui/select";
import { Header } from "@/components/header";
import { useToast } from "@/hooks/use-toast";

const DID_TYPES = [
  { value: "0", label: "Human" },
  { value: "1", label: "Organization" },
  { value: "2", label: "AI Agent" },
  { value: "3", label: "Smart Contract" },
];

const MODULE_ADDRESS = "0x61b96051f553d767d7e6dfcc04b04c28d793c8af3d07d3a43b4e2f8f4ca04c9f";

const config = new AptosConfig({
  fullnode: "https://aptos.testnet.bardock.movementlabs.xyz/v1",
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
  const { account, connected, signAndSubmitTransaction } = useAptosWallet();
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
  }, [connected, account, address, setFetchingInfo]);

  const fetchDidInfo = async (addressToFetch: string) => {
    try {
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
    console.log("handleCreateDid");
    if (!connected || !account?.address) {
      error("Please connect wallet first");
      return;
    }

    if (!didType || !description) {
      error("Please select DID type and enter description");
      return;
    }

    setLoading(true);
    try {
      const payload: InputEntryFunctionData = {
        function: `${MODULE_ADDRESS}::init::init`,
        typeArguments: [],
        functionArguments: [parseInt(didType), description],
      };

      const response = await signAndSubmitTransaction({ payload }) as unknown as { hash: string };
      console.log("Transaction hash:", response);
      
      try {
        const pendingTransaction = await client.waitForTransaction({
          transactionHash: response.hash ,
        });
        console.log("Transaction confirmed:", pendingTransaction);
        
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
            <div className="max-w-md mx-auto bg-[var(--pixel-card)] p-6 rounded-lg pixel-border">
              <h2 className="text-xl mb-4 pixel-text text-center">Loading DID Information...</h2>
              <div className="pixel-loading"></div>
            </div>
          ) : (
            <div className="space-y-6">
              {didInfo && (
                <div className="max-w-md mx-auto bg-[var(--pixel-card)] p-6 rounded-lg pixel-border">
                  <h2 className="text-xl mb-4 pixel-text">Your DID Information</h2>
                  <p className="mb-2">Type: {didInfo.type}</p>
                  <p>Description: {didInfo.description}</p>
                </div>
              )}
            </div>
            )}
          

          {!connected && (
            <div className="max-w-md mx-auto">
              <div className="text-center mb-6">
                <p className="mb-4 pixel-text text-[var(--pixel-accent)]">
                  <br></br>
                  Please Connect your wallet to create DID
                </p>
              </div>
            </div>
          )}
          {connected && (

            <div className="max-w-md mx-auto">
              <div className="bg-[var(--pixel-card)] p-6 rounded-lg pixel-border opacity-50">
                <h2 className="text-xl mb-4 pixel-text">Create DID</h2>
                <div className="space-y-4">
                  <SelectWrapper
                    onValueChange={(value) => {
                      // Handle the selected value here
                      console.log("Selected value:", value);
                      setDidType(value);
                    }}
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
                  </SelectWrapper>

                  <Input
                    placeholder="Enter description"
                    className="pixel-input"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />

                  <Button
                    // className="w-full pixel-button"
                    onClick={handleCreateDid}
                  >
                    Create DID
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
