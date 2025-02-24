import { toast as sonnerToast } from "sonner"

interface ToastOptions {
  title?: string
  description?: string
  duration?: number
  action?: {
    label: string
    onClick: () => void
  }
}

export function useToast() {
  const toast = (options: ToastOptions) => {
    return sonnerToast(options.title, {
      description: options.description,
      duration: options.duration || 5000,
      action: options.action && {
        label: options.action.label,
        onClick: options.action.onClick,
      },
    })
  }

  return {
    toast,
    success: (options: ToastOptions | string) => {
      if (typeof options === 'string') {
        return sonnerToast.success(options)
      }
      return sonnerToast.success(options.title, {
        description: options.description,
        duration: options.duration || 5000,
        className: "bg-gradient-to-r from-[var(--pixel-success)] to-[color-mix(in_srgb,var(--pixel-success)_70%,var(--pixel-card))] border-2 border-[var(--pixel-success)] text-white",
        action: options.action && {
          label: options.action.label,
          onClick: options.action.onClick,
        },
      })
    },
    error: (options: ToastOptions | string) => {
      if (typeof options === 'string') {
        return sonnerToast.error(options)
      }
      return sonnerToast.error(options.title, {
        description: options.description,
        duration: options.duration || 5000,
        className: "bg-gradient-to-r from-[var(--pixel-error)] to-[color-mix(in_srgb,var(--pixel-error)_70%,var(--pixel-card))] border-2 border-[var(--pixel-error)] text-white",
        action: options.action && {
          label: options.action.label,
          onClick: options.action.onClick,
        },
      })
    },
    warning: (options: ToastOptions | string) => {
      if (typeof options === 'string') {
        return sonnerToast.warning(options)
      }
      return sonnerToast.warning(options.title, {
        description: options.description,
        duration: options.duration || 5000,
        className: "bg-gradient-to-r from-[var(--pixel-warning)] to-[color-mix(in_srgb,var(--pixel-warning)_70%,var(--pixel-card))] border-2 border-[var(--pixel-warning)] text-white",
        action: options.action && {
          label: options.action.label,
          onClick: options.action.onClick,
        },
      })
    },
    info: (options: ToastOptions | string) => {
      if (typeof options === 'string') {
        return sonnerToast.info(options)
      }
      return sonnerToast.info(options.title, {
        description: options.description,
        duration: options.duration || 5000,
        className: "bg-gradient-to-r from-[var(--pixel-primary)] to-[color-mix(in_srgb,var(--pixel-primary)_70%,var(--pixel-card))] border-2 border-[var(--pixel-primary)] text-white",
        action: options.action && {
          label: options.action.label,
          onClick: options.action.onClick,
        },
      })
    },
    promise: async <T>(
      promise: Promise<T>,
      options: {
        loading: string
        success: string
        error: string
      }
    ) => {
      return sonnerToast.promise(promise, {
        loading: options.loading,
        success: options.success,
        error: options.error,
        className: "bg-[var(--pixel-card)] border-2 border-[var(--pixel-surface)] text-[var(--pixel-text-primary)]",
      })
    },
  }
} 