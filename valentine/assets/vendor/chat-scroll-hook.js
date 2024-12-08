const ChatScroll = {
    mounted() {
        this.scrollToBottom();
        // Create observer for child changes
        this.observer = new MutationObserver(() => {
            this.scrollToBottom();
        });

        // Observe child additions/removals
        this.observer.observe(this.el, {
            childList: true,
            subtree: true,
        });
    },

    updated() {
        this.scrollToBottom();
    },

    destroyed() {
        if (this.observer) {
            this.observer.disconnect();
        }
    },

    scrollToBottom() {
        // Use requestAnimationFrame to ensure DOM has updated
        requestAnimationFrame(() => {
            this.el.scrollTop = this.el.scrollHeight;
        });
    }
};

export default ChatScroll;