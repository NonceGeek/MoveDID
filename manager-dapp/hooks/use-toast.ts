import { toast } from "sonner"

export function useToast() {
  return {
    toast,
    success: (message: string) => 
      toast(message, {
        className: "pixel-toast-success",
      }),
    error: (message: string) =>
      toast(message, {
        className: "pixel-toast-error",
      }),
  }
} 