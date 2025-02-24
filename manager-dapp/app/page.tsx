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
import { AptosConnectButton } from "@razorlabs/wallet-kit";

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
      error({
        title: "Please connect wallet first",
        description: "Please try again.",
        duration: 5000,
      });
      return;
    }

    if (!didType || !description) {
      error({
        title: "Please select DID type and enter description",
        description: "Please try again.",
        duration: 5000,
      });
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
        success({
          title: "DID created successfully!",
          description: "Your digital identity has been created successfully!",
          duration: 5000,
        });
      } catch (err) {
        console.error("Error waiting for transaction:", err);
        error({
          title: "Transaction failed to confirm",
          description: "Please try again.",
          duration: 5000,
        });
      }
    } catch (err) {
      console.error("Error creating DID:", err);
      error({
        title: "Failed to create DID",
        description: "Please try again.",
        duration: 5000,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[var(--pixel-background)] text-[var(--pixel-text)]">
      <Header />
      <main className="container mx-auto px-4 py-8">
        <div className="pt-24 max-w-4xl mx-auto">
          {/* Enhanced Hero Section */}
          <div className="text-center mb-16">
            <h1 className="text-5xl font-bold mb-6 bg-gradient-to-r from-[var(--pixel-primary)] via-[var(--pixel-accent)] to-[var(--pixel-success)] bg-clip-text text-transparent">
              Your Digital Identity on Movement
            </h1>
            <p className="text-xl text-[var(--pixel-text-secondary)] mb-8 max-w-2xl mx-auto">
              Create and manage your decentralized identity in a few simple steps
            </p>
            <div className="flex items-center justify-center gap-6">
              <a
                href="https://x.com/intent/follow?screen_name=root_mud"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-3 px-6 py-3 rounded-full bg-[var(--pixel-surface)] hover:bg-[var(--pixel-surface)/80] transition-all duration-300"
              >
                <span className="text-[var(--pixel-text-primary)]">Follow us on X</span>
                <svg className="w-5 h-5" /* Add X/Twitter icon SVG here */ />
              </a>
            </div>
          </div>

          {/* Enhanced Loading State */}
          {fetchingInfo ? (
            <div className="bg-[var(--pixel-card)] p-8 rounded-2xl shadow-lg mb-8 text-center border border-[var(--pixel-surface)]">
              <h2 className="text-xl font-semibold mb-6">Loading Your Identity...</h2>
              <div className="flex justify-center">
                <div className="pixel-loading"></div>
              </div>
            </div>
          ) : didInfo ? (
            <div className="bg-[var(--pixel-card)] p-8 rounded-2xl shadow-lg mb-8 border border-[var(--pixel-surface)]">
              <h2 className="text-2xl font-semibold mb-6 bg-gradient-to-r from-[var(--pixel-primary)] to-[var(--pixel-accent)] bg-clip-text text-transparent">
                Existing DID Found for Your Wallet
              </h2>
              <div className="space-y-6">
                <div className="flex items-center gap-4 p-4 rounded-lg bg-[var(--pixel-surface)]">
                  <span className="text-[var(--pixel-text-secondary)] min-w-[100px]">Type:</span>
                  <span className="font-medium text-[var(--pixel-text-primary)]">{didInfo.type}</span>
                </div>
                <div className="flex items-center gap-4 p-4 rounded-lg bg-[var(--pixel-surface)]">
                  <span className="text-[var(--pixel-text-secondary)] min-w-[100px]">Description:</span>
                  <span className="font-medium text-[var(--pixel-text-primary)]">{didInfo.description}</span>
                </div>
              </div>
            </div>
          ) : null}

          {/* Enhanced Connection Status */}
          {!connected && (
            <div className="bg-[var(--pixel-card)] p-12 rounded-2xl shadow-lg text-center mb-8 border border-[var(--pixel-surface)]">
              <div className="max-w-md mx-auto">
                <h2 className="text-3xl font-semibold mb-6 bg-gradient-to-r from-[var(--pixel-primary)] to-[var(--pixel-accent)] bg-clip-text text-transparent">
                  Get Started
                </h2>
                <p className="text-lg text-[var(--pixel-text-secondary)] mb-8">
                  Connect your wallet to create and manage your digital identity
                </p>
                <div className="inline-block">
                  <AptosConnectButton 
                    className="px-8 py-4 text-lg font-semibold rounded-xl bg-gradient-to-r from-[var(--pixel-primary)] to-[var(--pixel-accent)] text-white hover:opacity-90 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Enhanced Create DID Form */}
          {connected && !didInfo && (
            <div className="bg-[var(--pixel-card)] p-8 rounded-2xl shadow-lg border border-[var(--pixel-surface)]">
              <h2 className="text-2xl font-semibold mb-8 bg-gradient-to-r from-[var(--pixel-primary)] to-[var(--pixel-accent)] bg-clip-text text-transparent">
                Create Your Identity
              </h2>
              <div className="max-w-md mx-auto space-y-8">
                <div className="space-y-3">
                  <label className="block text-base font-medium text-[var(--pixel-text-secondary)]">
                    Identity Type
                  </label>
                  <SelectWrapper
                    onValueChange={(value) => setDidType(value)}
                  >
                    <SelectTrigger className="w-full h-12 text-base bg-[var(--pixel-surface)] border-2 border-[var(--pixel-text-muted)] hover:border-[var(--pixel-accent)] transition-all duration-300">
                      <SelectValue placeholder="Choose your identity type" />
                    </SelectTrigger>
                    <SelectContent className="bg-[var(--pixel-card)] border-2 border-[var(--pixel-surface)]">
                      {DID_TYPES.map((type) => (
                        <SelectItem 
                          key={type.value} 
                          value={type.value}
                          className="hover:bg-[var(--pixel-surface)] cursor-pointer py-3"
                        >
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </SelectWrapper>
                </div>

                <div className="space-y-3">
                  <label className="block text-base font-medium text-[var(--pixel-text-secondary)]">
                    Description
                  </label>
                  <Input
                    placeholder="Tell us about yourself or your organization"
                    className="h-12 text-base bg-[var(--pixel-surface)] border-2 border-[var(--pixel-text-muted)] hover:border-[var(--pixel-accent)] transition-all duration-300"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />
                </div>

                <Button
                  className="w-full h-12 text-base font-semibold bg-gradient-to-r from-[var(--pixel-primary)] to-[var(--pixel-accent)] hover:opacity-90 transition-all duration-300 transform hover:-translate-y-1"
                  onClick={handleCreateDid}
                  disabled={loading}
                >
                  {loading ? 'Creating...' : 'Create Digital Identity'}
                </Button>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
