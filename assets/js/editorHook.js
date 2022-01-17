import {deleteBackwardsTowardsSentenceStart, 
        insertLineAfterCurrent,
        moveCaretForwardTowardsNextSentence,
        deleteWordPartLeft,
        deleteWordPartRight,
        deleteCharRight,
        moveCaretBackwardsSentenceWise,
        caretLeft,
        caretRight,
        moveCaretWordLeft,
        moveCaretWordRight,
        moveCaretWordPartLeft,
        moveCaretWordPartRight} from "./editor"

export const editorHook = {
    controlPressed: false,
    shiftPressed: false,
    altPressed: false,
    metaPressed: false,
    mounted() {
        this.el.addEventListener("mouseleave", function(e) {
            this.controlPressed = false
            this.shiftPressed = false
            this.altPressed = false
            this.metaPressed = false
        })
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

            const applyIt = ([resultSelection, resultValue]) => {

                e.preventDefault()
                this.value = resultValue
                this.selectionStart = this.selectionEnd = resultSelection
            }

            if (this.controlPressed 
                && !this.shiftPressed 
                && !this.metaPressed 
                && !this.altPressed 
                && e.code === "KeyJ") {

                applyIt(caretLeft([this.selectionStart, this.value]))                
            }

            if (this.controlPressed 
                && !this.shiftPressed 
                && !this.metaPressed 
                && !this.altPressed 
                && e.code === "KeyL") {

                applyIt(caretRight([this.selectionStart, this.value]))                
            }

            if (this.altPressed 
                && !this.metaPressed 
                && !this.shiftPressed 
                && e.code === "Backspace") {

                applyIt(deleteBackwardsTowardsSentenceStart([this.selectionStart, this.value]))                
            }

            if (this.altPressed
                && !this.metaPressed
                && !this.shiftPressed
                && e.code === "KeyJ") {

                applyIt(moveCaretBackwardsSentenceWise([this.selectionStart, this.value]))
            }

            if (this.altPressed
                && !this.metaPressed
                && !this.shiftPressed
                && e.code === "KeyL") {

                applyIt(moveCaretForwardTowardsNextSentence([this.selectionStart, this.value]))
            }

            if (!this.altPressed 
                && !this.metaPressed 
                && this.shiftPressed 
                && e.key === "Enter") {
                
                applyIt(insertLineAfterCurrent([this.selectionStart, this.value]))
            }

            if (!this.shiftPressed 
                && this.metaPressed 
                && !this.altPressed  
                && e.code === "KeyJ") {
                
                applyIt(moveCaretWordPartLeft([this.selectionStart, this.value]))
            }
            if (!this.shiftPressed 
                && this.metaPressed 
                && this.altPressed 
                && e.code === "KeyJ") {
                
                applyIt(moveCaretWordLeft([this.selectionStart, this.value]))
            }

            if (!this.shiftPressed 
                && this.metaPressed 
                && !this.altPressed 
                && e.code === "KeyL") {
                
                applyIt(moveCaretWordPartRight([this.selectionStart, this.value]))
            }
            if (!this.shiftPressed 
                && this.metaPressed 
                && this.altPressed 
                && e.code === "KeyL") {
                
                applyIt(moveCaretWordRight([this.selectionStart, this.value]))
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

            if (!this.controlPressed 
                && this.shiftPressed 
                && !this.metaPressed 
                && !this.altPressed
                && e.code === "Backspace") {
            
                applyIt(deleteCharRight([this.selectionStart, this.value]))
            }

            if (!this.controlPressed 
                && !this.shiftPressed 
                && this.metaPressed 
                && !this.altPressed
                && e.code === "Backspace") {
            
                applyIt(deleteWordPartLeft([this.selectionStart, this.value]))
            }

            if (!this.controlPressed 
                && this.shiftPressed 
                && this.metaPressed 
                && !this.altPressed
                && e.code === "Backspace") {
            
                applyIt(deleteWordPartRight([this.selectionStart, this.value]))
            }

            if (e.code === "ControlLeft") this.controlPressed = true
            if (e.code === "ShiftLeft") this.shiftPressed = true
            if (e.code === "MetaLeft") this.metaPressed = true
            if (e.code === "AltLeft") this.altPressed = true
        })
        this.el.addEventListener("keyup", function(e) {

            if (e.code === "ControlLeft") this.controlPressed = false
            if (e.code === "ShiftLeft") this.shiftPressed = false
            if (e.code === "MetaLeft") this.metaPressed = false
            if (e.code === "AltLeft") this.altPressed = false
        })
    }
}