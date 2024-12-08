const ResizableDrawer = {
    mounted() {
        const drawer = this.el;
        const handle = drawer.querySelector('.resize-handle');
        let isResizing = false;
        let startX;
        let startWidth;

        const startResize = (e) => {
            isResizing = true;
            startX = e.clientX;
            startWidth = parseInt(getComputedStyle(drawer).width, 10);

            drawer.classList.add('is-resizing');
            handle.classList.add('is-resizing');
            document.addEventListener('mousemove', resize);
            document.addEventListener('mouseup', stopResize);
        };

        const resize = (e) => {
            if (!isResizing) return;

            const width = startWidth - (e.clientX - startX);

            // Apply min/max constraints
            const minWidth = 200;
            const maxWidth = window.innerWidth * 0.5;
            const newWidth = Math.min(Math.max(width, minWidth), maxWidth);

            drawer.style.width = `${newWidth}px`;
        };

        const stopResize = () => {
            isResizing = false;
            drawer.classList.remove('is-resizing');
            handle.classList.remove('is-resizing');
            document.removeEventListener('mousemove', resize);
            document.removeEventListener('mouseup', stopResize);
        };

        handle.addEventListener('mousedown', startResize);

        // Cleanup
        this.destroy = () => {
            handle.removeEventListener('mousedown', startResize);
            document.removeEventListener('mousemove', resize);
            document.removeEventListener('mouseup', stopResize);
        };
    },

    destroyed() {
        if (this.destroy) this.destroy();
    }
};

export default ResizableDrawer;