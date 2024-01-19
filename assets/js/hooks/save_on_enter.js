let SaveOnEnter = {
    mounted() {
        this.el.addEventListener("keydown", (event) => {
            if (event.key === "Enter") {
                event.preventDefault()
                this.pushEventTo(this.el, "update_entry")
            }
        })
    }
}


export default SaveOnEnter