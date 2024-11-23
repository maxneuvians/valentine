// assets/js/hooks/auto_hide_flash.js
const AutoHideFlash = {
    updatedFlashTimeouts: new Map(),

    updated() {
        const autoHide = this.el.dataset.autoHide === "true"
        const hideAfter = parseInt(this.el.dataset.hideAfter)

        if (autoHide && !isNaN(hideAfter)) {
            // Get all flash messages
            this.el.querySelectorAll('.flash').forEach(alert => {
                const flashId = alert.id

                // Clear existing timeout for this flash if it exists
                if (this.updatedFlashTimeouts.has(flashId)) {
                    clearTimeout(this.updatedFlashTimeouts.get(flashId))
                }

                // Set new timeout
                const timeout = setTimeout(() => {
                    alert.style.transition = "opacity 0.5s ease-out"
                    alert.style.opacity = "0"

                    setTimeout(() => {
                        this.pushEvent("lv:clear-flash")
                        this.updatedFlashTimeouts.delete(flashId)
                    }, 500)
                }, hideAfter)

                // Store the timeout reference
                this.updatedFlashTimeouts.set(flashId, timeout)
            })
        }
    },

    // Clean up timeouts when the element is removed
    destroyed() {
        this.updatedFlashTimeouts.forEach(timeout => clearTimeout(timeout))
        this.updatedFlashTimeouts.clear()
    }
}

export default AutoHideFlash