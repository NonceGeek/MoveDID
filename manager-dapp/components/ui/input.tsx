import * as React from "react"

import { cn } from "@/lib/utils"

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: boolean
  icon?: React.ReactNode
}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, error, icon, ...props }, ref) => {
    return (
      <div className="relative">
        {icon && (
          <div className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--pixel-text-secondary)]">
            {icon}
          </div>
        )}
        <input
          type={type}
          className={cn(
            // Base styles
            "w-full rounded-md border bg-transparent transition-all duration-200",
            "h-10 px-3 py-2 text-base md:text-sm",
            
            // Icon padding
            icon && "pl-10",
            
            // Default state
            "border-[var(--pixel-text-muted)]",
            "text-[var(--pixel-text-primary)]",
            "placeholder:text-[var(--pixel-text-secondary)]",
            
            // Focus state
            "focus:outline-none",
            "focus:border-[var(--pixel-accent)]",
            "focus:ring-2",
            "focus:ring-[var(--pixel-accent)]",
            "focus:ring-opacity-20",
            
            // Error state
            error && [
              "border-[var(--pixel-error)]",
              "focus:border-[var(--pixel-error)]",
              "focus:ring-[var(--pixel-error)]",
            ],
            
            // Disabled state
            "disabled:opacity-70",
            "disabled:cursor-not-allowed",
            
            className
          )}
          ref={ref}
          {...props}
        />
      </div>
    )
  }
)
Input.displayName = "Input"

export { Input }
