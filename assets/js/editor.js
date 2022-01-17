export function isAltStop(s) {
    return s === "." 
    || s === "," 
    || s === ";" 
    || s === "\t" 
    || s === "\n"
    || s === " "
}

function isSentenceStop(s) {
    return s === "." || s === "," || s === ";"
}

function isWhitespace(s) {
    return s === " " || s === "\n"
}

export function insertLineAfterCurrent([selectionStart, value]) {

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

function backwardsTowardsSentenceStart([selectionStart, value]) {

    if (selectionStart > 2
        && value[selectionStart-1] === "\n"
        && value[selectionStart-2] === "\n") return selectionStart-1
    
    if (selectionStart > 0) {
        if (isSentenceStop(value[selectionStart-1])) selectionStart--
    } 
    let onlyWhitespace = true
    for (; selectionStart > 0; selectionStart--) {
        if (isSentenceStop(value[selectionStart-1])) break
        else if (selectionStart > 2 
            && value[selectionStart-1] === "\n"
            && value[selectionStart-2] === "\n") break
        if (!isWhitespace(value[selectionStart-1])) onlyWhitespace = false
    }
    if (!onlyWhitespace) for (; selectionStart < value.length; selectionStart++) {
        if (!isWhitespace(value[selectionStart])) break;
    }

    return selectionStart
}

function forwardTowardsSentenceStart([selectionStart, value]) {

    if (selectionStart + 1 < value.length
        && value[selectionStart] === "\n"
        && value[selectionStart+1] === "\n") return selectionStart+1

    for (; selectionStart < value.length; selectionStart++) {
        if (isSentenceStop(value[selectionStart])) return selectionStart + 1

        if (value[selectionStart] === "\n" 
            && selectionStart + 1 < value.length 
            && value[selectionStart+1] === "\n") {

            return selectionStart
        }
    }
    return selectionStart
}

function wordPartLeft([selectionStart, value]) {

    selectionStart--

    if (selectionStart >= 0) {
        if (value[selectionStart] === " ") {
            for (; selectionStart > 0; selectionStart--) {
                if (value[selectionStart] !== " ") return selectionStart + 1
            }
        }
        if (isAltStop(value[selectionStart])) return selectionStart
    }

    for (; selectionStart >= 0; selectionStart--) {
        if (isAltStop(value[selectionStart])) break
        else if (selectionStart === 0) return 0
    }
    return selectionStart + 1
}

function wordRight([selectionStart, value]) {
   
    let i = selectionStart
    if (i < value.length) {
        if (isAltStop(value[i])) {
            for (; i < value.length && isAltStop(value[i]); i++);
        } 
        for (; i < value.length && !isAltStop(value[i]); i++);
    }
    return i
}

function wordLeft([selectionStart, value]) {

    let i = selectionStart
    if (i > 0) {
        if (isAltStop(value[i-1])) {
            for (; i > 0 && isAltStop(value[i-1]); i--);
        } 
        for (; i > 0 && !isAltStop(value[i-1]); i--);
    }
    return i
}

function wordPartRight([selectionStart, value]) {
   
    selectionStart++
    if (value[selectionStart-1] === " ") {
        
        for (; selectionStart < value.length 
            && value[selectionStart] === " "; selectionStart++);
        return selectionStart
    } else if (isAltStop(value[selectionStart-1])) return selectionStart

    for (; selectionStart < value.length 
        && !isAltStop(value[selectionStart]); selectionStart++);
    return selectionStart
}

function cleft([selectionStart, _value]) {
   
    return selectionStart > 0 ? selectionStart - 1 : selectionStart
}

function cright([selectionStart, value]) {
   
    return selectionStart < value.length -1 ? selectionStart + 1 : selectionStart
}

export function moveCaretForwardTowardsNextSentence(params) {

    return [forwardTowardsSentenceStart(params), params[1]]
}

export function moveCaretBackwardsSentenceWise(params) {

    return [backwardsTowardsSentenceStart(params), params[1]]
}

export function moveCaretWordLeft(params) {
    
    return [wordLeft(params), params[1]]
}

export function moveCaretWordPartLeft(params) {
    
    return [wordPartLeft(params), params[1]]
}

export function moveCaretWordRight(params) {

    return [wordRight(params), params[1]]
}

export function moveCaretWordPartRight(params) {

    return [wordPartRight(params), params[1]]
}

export function caretLeft(params) {

    return [cleft(params), params[1]]
}

export function caretRight(params) {

    return [cright(params), params[1]]
}

export function deleteWordPartLeft(params) {

    const [selectionStart_, value] = params
    const selectionStart = wordPartLeft(params)    

    const resultValue = 
        value.slice(0, selectionStart)
        + value.slice(selectionStart_, value.length)

    return [selectionStart, resultValue]
}

export function deleteWordPartRight(params) {

    const [selectionStart_, value] = params
    const selectionStart = wordPartRight(params)    

    const resultValue = 
        value.slice(0, selectionStart_)
        + value.slice(selectionStart, value.length)

    return [selectionStart_, resultValue]
}

export function deleteBackwardsTowardsSentenceStart(params) {

    const [selectionStart_, value] = params
    
    const selectionStart = backwardsTowardsSentenceStart(params)
    
    const resultValue = 
        value.slice(0, selectionStart)
        + value.slice(selectionStart_, value.length)

    return [selectionStart, resultValue]
}
