function isAltStop(s) {
    return s === " " || s === "." || s === "\t" || s === "\n"
}

export const editorHook = {
    altPressed: false,
    metaPressed: false,
    shiftPressed: false,
    mounted() {
        this.el.addEventListener("keydown", function(e) {

            /* 
             * This is for using tabs for indentation, as is the usual behaviour.
             * https://stackoverflow.com/a/6637396
             */ 
            if (e.key === "Tab") {
              e.preventDefault();
              var start = this.selectionStart;
              var end = this.selectionEnd;
              this.value = this.value.substring(0, start) +
                "    " + this.value.substring(end)  
              this.selectionStart =
                this.selectionEnd = start + 4
            }

            if (this.shiftPressed) {
                if (e.key === "Enter") {
                    e.preventDefault()
                    let i = this.selectionStart
                    console.log("here", i)
                    if (i === this.value.length) {
                        this.value += "\n"
                        this.selectionStart = this.selectionEnd = i + 1
                    } 
                    else for (; i < this.value.length; i++) {
                        if (this.value[i] === "\n") {
                            this.value = 
                                this.value.slice(0, i) 
                                + "\n" 
                                + this.value.slice(i, this.value.length)
                            this.selectionStart = this.selectionEnd = i + 1
                            break
                        }
                        else if (i + 1 === this.value.length) {
                            this.value += "\n"
                            this.selectionStart = this.selectionEnd = i + 2
                            break
                        }
                    }
                }
            }

            if (this.metaPressed && e.code === "KeyJ") {
                e.preventDefault()
                let i = this.selectionEnd
                if (i > 0) {
                    if (this.altPressed) {
                        if (isAltStop(this.value[i-1])) {
                            for (; i > 0 && isAltStop(this.value[i-1]); i--);
                        } 
                        for (; i > 0 && !isAltStop(this.value[i-1]); i--);
                    } else {
                        if (isAltStop(this.value[i-1])) {
                            for (; i > 0 && isAltStop(this.value[i-1]); i--);
                        } else {
                            for (; i > 0 && !isAltStop(this.value[i-1]); i--);
                        }
                    }
                }
                this.selectionStart = this.selectionEnd = i
            }
            if (this.metaPressed && e.code === "KeyL") {
                e.preventDefault()
                let i = this.selectionStart
                if (i < this.value.length) {
                    if (this.altPressed) {
                        if (isAltStop(this.value[i])) {
                            for (; i < this.value.length && isAltStop(this.value[i]); i++);
                        }
                        for (; i < this.value.length && !isAltStop(this.value[i]); i++);
                    } else {
                        if (isAltStop(this.value[i])) {
                            for (; i < this.value.length && isAltStop(this.value[i]); i++);
                        } else {
                            for (; i < this.value.length && !isAltStop(this.value[i]); i++);
                        }
                    }
                }
                this.selectionStart = this.selectionEnd = i
            }
            if (e.code === "AltLeft") this.altPressed = true
            if (e.code === "MetaLeft") this.metaPressed = true
            if (e.code === "ShiftLeft") this.shiftPressed = true
        })
        this.el.addEventListener("keyup", function(e) {

            if (e.code === "AltLeft") this.altPressed = false
            if (e.code === "MetaLeft") this.metaPressed = false
            if (e.code === "ShiftLeft") this.shiftPressed = false
        })
    }
}