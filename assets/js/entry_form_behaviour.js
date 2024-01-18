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


function getFormData(inputElement){
    let formData = new FormData(inputElement.form)

    console.log(Object.fromEntries(formData))
}


Hooks.SaveOnEnter = {
    mounted() {
        this.el.addEventListener("keydown", (event) => {
            if (event.key === "Enter") {
                console.log("it happened!")
                console.log({event})
                event.preventDefault()
                getFormData(this.el)
                this.pushEventTo(this.el, "update_entry")
            }
        })
    }
}




export default Hooks;