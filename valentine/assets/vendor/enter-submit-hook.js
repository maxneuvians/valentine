const EnterSubmitHook = {
    mounted() {
        this.el.addEventListener("keydown", (e) => {
            if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault(); // Prevent default Enter behavior

                if (this.el.value) {
                    this.pushEventTo(this.el, "chat_submit", { value: this.el.value.trim() });
                }
                this.el.value = "";
            }
        });
    },
}

export default EnterSubmitHook