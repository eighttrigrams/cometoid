function isAltStop(s) {
    return s === " " || s === "." || s === "\t" || s === "\n"
}

function isSentenceStop(s) {
    return s === "." || s === "," || s === ";"
}

function isWhitespace(s) {
    return s === " " || s === "\n"
}

function insertLineAfterCurrent(selectionStart, value) {

    let resultValue = value
    let offset = 1

    if (selectionStart === value.length) resultValue += "\n"
    else for (; selectionStart < value.length; selectionStart++) {
        if (value[selectionStart] === "\n") {
            resultValue = 
                value.slice(0, selectionStart) 
                + "\n" 
                + value.slice(selectionStart, value.length)
            break
        }
        else if (selectionStart + 1 === value.length) {
            resultValue += "\n"
            offset++
            break
        }
    }

    return [selectionStart + offset, resultValue]
}

function deleteBackwardsTowardsSentenceStart(selectionStart, value) {

    let resultValue = value
    let offset = 0
    let _selectionStart = selectionStart

    if (selectionStart === 0) return [selectionStart, value]

    if (selectionStart > 0) {
        if (value[selectionStart-1] === "\n") {
            resultValue = value.slice(0, selectionStart-1) 
                + value.slice(selectionStart, value.length)
            return [selectionStart - 1, resultValue]
        }
        else if (isSentenceStop(value[selectionStart-1])) selectionStart--
    }
    for (; selectionStart > 0; selectionStart--) {
        if (selectionStart - 1 === 0) {
            resultValue = value.slice(_selectionStart, value.length)
            offset--
            break;
        } else if (isSentenceStop(value[selectionStart-1])) {
            resultValue = 
                value.slice(0, selectionStart)
                + value.slice(_selectionStart, value.length)
            break;
        } else if (value[selectionStart-1] === "\n") {
            if (selectionStart > 1 && value[selectionStart-2] === "\n") {
                resultValue = 
                    value.slice(0, selectionStart)
                    + value.slice(_selectionStart, value.length)
                break
            }
        }
    }

    return [selectionStart + offset, resultValue]
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

            if (this.altPressed && !this.metaPressed && !this.shiftPressed && e.code === "Backspace") {
                e.preventDefault()
                
                const [resultSelection, resultValue] = 
                    deleteBackwardsTowardsSentenceStart(this.selectionStart, this.value)

                this.value = resultValue
                this.selectionStart = this.selectionEnd = resultSelection
            }

            if (!this.altPressed && !this.metaPressed && this.shiftPressed && e.key === "Enter") {
                e.preventDefault()
                const [resultSelection, resultValue] = 
                    insertLineAfterCurrent(this.selectionStart, this.value)

                this.value = resultValue
                this.selectionStart = this.selectionEnd = resultSelection
            }

            if (this.altPressed && e.key === "Enter") {
                e.preventDefault()
                let i = this.selectionStart
                if (i === 0) {
                    this.value = "\n" + this.value
                    this.selectionStart = this.selectionEnd = 0
                } else {
                    if (this.value[i] === "\n") i--
                    for (; i >= 0; i--) {
                        if (this.value[i] === "\n") {
                            this.value =
                                this.value.slice(0, i+1)
                                + "\n"
                                + this.value.slice(i+1, this.value.length)
                            this.selectionStart = this.selectionEnd = i + 1
                            break
                        } 
                        else if (i === 0) {
                            this.value =
                                "\n"
                                + this.value
                            this.selectionStart = this.selectionEnd = 0
                            break
                        }
                    }
                }
            }

            if (this.metaPressed && e.code === "Backspace") {
            
                e.preventDefault()

                if (this.shiftPressed) {
                    let i = this.selectionStart
                    
                    if (i < this.value.length) {
                        // TODO dedup #A
                        if (isAltStop(this.value[i])) {
                            for (; i < this.value.length && isAltStop(this.value[i]); i++);
                        } else {
                            for (; i < this.value.length && !isAltStop(this.value[i]); i++);
                        }
                        const start = this.selectionStart
                        this.value = 
                            this.value.slice(0, this.selectionStart)
                            + this.value.slice(i, this.value.length) 
                        this.selectionStart = this.selectionEnd = start
                    }
                } else {
                    let i = this.selectionEnd
                    if (i > 0) {
                        // TODO dedup #A
                        if (isAltStop(this.value[i-1])) {
                            for (; i > 0 && isAltStop(this.value[i-1]); i--);
                        } else {
                            for (; i > 0 && !isAltStop(this.value[i-1]); i--);
                        }
                        this.value = 
                            this.value.slice(0, i)
                            + this.value.slice(this.selectionEnd, this.value.length)
                        this.selectionStart = this.selectionEnd = i
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
                        // TODO dedup #A
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