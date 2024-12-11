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
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                })
                .catch(error => {
                    console.error('Error updating session:', error);
                });
        })
    }
}

export default Session