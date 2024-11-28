import Quill from 'quill';
import "quill/dist/quill.snow.css";


const QuillHook = {
    mounted() {
        this.initializeQuill();
    },

    updated() {
        console.log("Quill Hook updated");
    },

    destroyed() {
        console.log("Quill Hook destroyed");
    },

    initializeQuill() {
        this.q = new Quill(document.getElementById("quill-editor"), {
            theme: 'snow'
        });
        this.bindEvents();
        this.setupEventHandlers();
    },

    bindEvents() {
        this.q.on('text-change', (delta, oldDelta, source) => {
            if (source === 'user') {
                this.pushEventTo(this.el, "quill-change", {
                    delta: delta,
                    oldDelta: oldDelta,
                    source: source
                });
            }
        });
    },

    setupEventHandlers() {
        this.handleEvent("updateQuill", ({ event, payload }) => {
            switch (event) {
                case "text_change":
                    this.processTextChange(payload);
                    break;

                default:
                    console.error("Unknown event:", event);
            }
        });
    },

    processTextChange(payload) {
        this.q.updateContents(payload);
    }
};

export default QuillHook;