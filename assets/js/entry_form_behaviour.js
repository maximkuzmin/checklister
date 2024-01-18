let Hooks = {};

// const ADD_ENTRY = "add_entry";

// Hooks.NewEntryForm = {
//     mounted() {
//         this.el.addEventListener("keydown", (event) => {
//             if (event.key === "Enter"){
//                 console.log({event});
//                 event.preventDefault();
//                 this.pushEvent(ADD_ENTRY)
//             }
//         });
//     }
// }

// Hooks.AddEntryButtons = {
//     mounted() {
//         this.el.addEventListener("click", (event) => {
//             event.preventDefault();
//             console.log("Hey from click");
//             this.pushEvent("add_entry");
//         })
//     }
// }



Hooks.SaveOnEnter = {
    mounted() {
        this.el.addEventListener("keydown", (event) => {
            if (event.key === "Enter") {
                event.preventDefault()
                this.pushEventTo(this.el, "update_entry")
            }
        })
    }
}

Hooks.AddEntry = {
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




export default Hooks;