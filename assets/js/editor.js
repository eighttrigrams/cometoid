function isAltStop(s) {
    return s === " " || s === "." || s === "\t" || s === "\n"
}

export const editorHook = {
    altPressed: false,
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
            if (this.altPressed && e.code === "KeyJ") {
                let i = this.selectionEnd
                if (i > 0) {
                    if (isAltStop(this.value[i-1])) {
                        for (; i > 0 && isAltStop(this.value[i-1]); i--);
                    } else {
                        for (; i > 0 && !isAltStop(this.value[i-1]); i--);
                    }
                }
                this.selectionStart = this.selectionEnd = i
            }
            if (this.altPressed && e.code === "KeyL") {
                let i = this.selectionStart
                if (i < this.value.length) {
                    if (isAltStop(this.value[i])) {
                        for (; i < this.value.length && isAltStop(this.value[i]); i++);
                    } else {
                        for (; i < this.value.length && !isAltStop(this.value[i]); i++);
                    }
                }
                this.selectionStart = this.selectionEnd = i
            }
            if (e.key === "Alt" || e.key === "AltGraph") this.altPressed = true;
        })
        this.el.addEventListener("keyup", function(e) {

            if (e.key === "Alt" || e.key === "AltGraph") this.altPressed = false;
        })
    }
}