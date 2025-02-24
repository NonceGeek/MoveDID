import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all",
  {
    variants: {
      variant: {
        default: [
          "bg-[var(--pixel-primary)] text-white",
          "shadow-sm hover:shadow-md",
          "hover:bg-[color-mix(in_srgb,var(--pixel-primary)_90%,white)]",
          "active:scale-[0.98]",
          "disabled:opacity-70 disabled:pointer-events-none",
        ],
        secondary: [
          "bg-[var(--pixel-secondary)] text-white",
          "shadow-sm hover:shadow-md",
          "hover:bg-[color-mix(in_srgb,var(--pixel-secondary)_90%,white)]",
          "active:scale-[0.98]",
        ],
        outline: [
          "border-2 border-[var(--pixel-primary)]",
          "text-[var(--pixel-primary)]",
          "bg-transparent",
          "hover:bg-[var(--pixel-primary)] hover:text-white",
          "active:scale-[0.98]",
        ],
        ghost: [
          "bg-transparent",
          "text-[var(--pixel-text-primary)]",
          "hover:bg-[var(--pixel-surface)]",
          "active:scale-[0.98]",
        ],
        destructive: [
          "bg-[var(--pixel-error)] text-white",
          "shadow-sm hover:shadow-md",
          "hover:bg-[color-mix(in_srgb,var(--pixel-error)_90%,white)]",
          "active:scale-[0.98]",
        ],
        link: [
          "text-[var(--pixel-primary)]",
          "underline-offset-4",
          "hover:underline",
        ],
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-8 px-3 text-xs",
        lg: "h-12 px-6 text-base",
        icon: "h-10 w-10 p-2",
      },
      loading: {
        true: "relative text-transparent transition-none hover:text-transparent",
      }
    },
    defaultVariants: {
      variant: "default",
      size: "default",
      loading: false,
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
  loading?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, loading, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, loading, className }))}
        ref={ref}
        disabled={props.disabled || loading}
        {...props}
      >
        {loading && (
          <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
            <div className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
          </div>
        )}
        {props.children}
      </Comp>
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
