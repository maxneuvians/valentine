const Session = {
    mounted() {
        const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

        this.handleEvent('session', data => {
            fetch('/session', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token
                },
                body: JSON.stringify(data)
            })
        })
    }
}

export default Session