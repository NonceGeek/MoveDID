"use client"

import * as React from "react"
import * as ToastPrimitives from "@radix-ui/react-toast"
import { cva, type VariantProps } from "class-variance-authority"
import { X, CheckCircle2, AlertCircle, AlertTriangle } from "lucide-react"
import { cn } from "@/lib/utils"

const ToastProvider = ToastPrimitives.Provider

const ToastViewport = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Viewport>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Viewport>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Viewport
    ref={ref}
    className={cn(
      "fixed z-[100] flex max-h-screen w-full flex-col-reverse gap-3 p-4",
      "sm:bottom-0 sm:right-0 sm:top-auto sm:flex-col md:max-w-[420px]",
      "toast-viewport-animation",
      className
    )}
    {...props}
  />
))
ToastViewport.displayName = ToastPrimitives.Viewport.displayName

const toastVariants = cva(
  [
    "group pointer-events-auto relative flex w-full items-center overflow-hidden rounded-xl shadow-lg",
    "transition-all duration-300 ease-in-out",
    "data-[swipe=cancel]:translate-x-0",
    "data-[swipe=end]:translate-x-[var(--radix-toast-swipe-end-x)]",
    "data-[swipe=move]:translate-x-[var(--radix-toast-swipe-move-x)]",
    "data-[swipe=move]:transition-none",
    "data-[state=open]:animate-in",
    "data-[state=closed]:animate-out",
    "data-[state=closed]:fade-out-80",
    "data-[state=closed]:slide-out-to-right-full",
    "data-[state=open]:slide-in-from-top-full",
    "data-[state=open]:sm:slide-in-from-bottom-full",
    "hover:shadow-xl transform hover:-translate-y-1",
    "backdrop-blur-sm",
  ],
  {
    variants: {
      variant: {
        default: [
          "bg-[var(--pixel-card)]",
          "border-2 border-[var(--pixel-surface)]",
          "text-[var(--pixel-text-primary)]",
          "bg-opacity-95",
        ],
        success: [
          "bg-gradient-to-r from-[var(--pixel-success)] to-[color-mix(in_srgb,var(--pixel-success)_70%,var(--pixel-card))]",
          "border-2 border-[var(--pixel-success)]",
          "text-white",
        ],
        error: [
          "bg-gradient-to-r from-[var(--pixel-error)] to-[color-mix(in_srgb,var(--pixel-error)_70%,var(--pixel-card))]",
          "border-2 border-[var(--pixel-error)]",
          "text-white",
        ],
        warning: [
          "bg-gradient-to-r from-[var(--pixel-warning)] to-[color-mix(in_srgb,var(--pixel-warning)_70%,var(--pixel-card))]",
          "border-2 border-[var(--pixel-warning)]",
          "text-white",
        ],
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

const Toast = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Root>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Root> &
    VariantProps<typeof toastVariants>
>(({ className, variant, children, ...props }, ref) => {
  const icon = variant === 'success' ? <CheckCircle2 className="h-5 w-5" /> :
               variant === 'error' ? <AlertCircle className="h-5 w-5" /> :
               variant === 'warning' ? <AlertTriangle className="h-5 w-5" /> : null;

  return (
    <ToastPrimitives.Root
      ref={ref}
      className={cn(toastVariants({ variant }), className)}
      {...props}
    >
      <div className="flex items-center gap-3 p-4 w-full">
        {icon && <div className="flex-shrink-0">{icon}</div>}
        <div className="flex-1">{children}</div>
      </div>
    </ToastPrimitives.Root>
  )
})
Toast.displayName = ToastPrimitives.Root.displayName

const ToastAction = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Action>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Action>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Action
    ref={ref}
    className={cn(
      "inline-flex items-center justify-center rounded-md px-3 py-2",
      "text-sm font-medium transition-colors",
      "bg-transparent hover:bg-[rgba(255,255,255,0.1)]",
      "focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-30",
      "disabled:pointer-events-none disabled:opacity-50",
      className
    )}
    {...props}
  />
))
ToastAction.displayName = ToastPrimitives.Action.displayName

const ToastClose = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Close>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Close>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Close
    ref={ref}
    className={cn(
      "absolute right-2 top-2 rounded-md p-1",
      "text-white/80 opacity-0 transition-opacity",
      "hover:text-white hover:bg-white/10",
      "group-hover:opacity-100",
      "focus:opacity-100 focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-30",
      className
    )}
    toast-close=""
    {...props}
  >
    <X className="h-4 w-4" />
  </ToastPrimitives.Close>
))
ToastClose.displayName = ToastPrimitives.Close.displayName

const ToastTitle = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Title>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Title>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Title
    ref={ref}
    className={cn("text-sm font-semibold leading-none tracking-tight", className)}
    {...props}
  />
))
ToastTitle.displayName = ToastPrimitives.Title.displayName

const ToastDescription = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Description>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Description>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Description
    ref={ref}
    className={cn("text-sm opacity-90 leading-relaxed", className)}
    {...props}
  />
))
ToastDescription.displayName = ToastPrimitives.Description.displayName

// Add this to your globals.css
const styles = `
  @keyframes toast-viewport-show {
    from {
      opacity: 0;
      transform: translateY(2rem);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .toast-viewport-animation {
    animation: toast-viewport-show 0.3s ease-out;
  }

  @keyframes slide-in-from-right {
    from {
      transform: translateX(100%);
    }
    to {
      transform: translateX(0);
    }
  }

  [data-state="open"] {
    animation: slide-in-from-right 0.3s ease-out;
  }

  [data-state="closed"] {
    animation: slide-out-to-right 0.2s ease-in;
  }

  @keyframes slide-out-to-right {
    from {
      transform: translateX(0);
    }
    to {
      transform: translateX(100%);
    }
  }
`

export {
  ToastProvider,
  ToastViewport,
  Toast,
  ToastTitle,
  ToastDescription,
  ToastClose,
  ToastAction,
  styles as toastStyles,
} 