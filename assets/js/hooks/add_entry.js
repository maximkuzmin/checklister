let AddEntry = {
    mounted() {
        this.el.addEventListener("keydown", (event) => {
            if (event.key === "Enter") {
                event.preventDefault()

                this.pushEventTo(this.el, "add_entry")
                this.el.value = ""
            }
        })
    }
}


export default AddEntry;