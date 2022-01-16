export function isAltStop(s) {
    return s === " " || s === "." || s === "\t" || s === "\n"
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

    if (selectionStart > 2) {
        if (value[selectionStart-1] === " " && value[selectionStart-2] === ".") {
            return backwardsTowardsSentenceStart([selectionStart-1, value])
        }
        if (value[selectionStart-1] === "\n" && value[selectionStart-2] === "\n") {
            return selectionStart - 1
        }
    }
    if (selectionStart > 0) {
        if (isSentenceStop(value[selectionStart-1])) selectionStart--
    }
    for (; selectionStart > 0; selectionStart--) {
        if (selectionStart - 1 === 0) {
            selectionStart --
            break;
        } else if (isSentenceStop(value[selectionStart-1])) {
            
            break;
        } else if (value[selectionStart-1] === "\n") {
            if (selectionStart > 1 && value[selectionStart-2] === "\n") {
                break
            }
        }
    }

    return selectionStart
}

function forwardTowardsSentenceStart([selectionStart, value]) {

    for (; selectionStart < value.length; selectionStart++) {
        if (isSentenceStop(value[selectionStart])) {
            if (selectionStart + 1 < value.length) selectionStart += 2
            break
        }
        if (value[selectionStart] === "\n" 
            && selectionStart + 1 < value.length 
            && value[selectionStart+1] === "\n") {

            selectionStart += 2
            break;
        }
    }
    return selectionStart
}

export function moveCaretForwardTowardsNextSentence(params) {

    return [forwardTowardsSentenceStart(params), params[1]]
}

export function moveCaretBackwardsTowardsSentenceStart(params) {

    return [backwardsTowardsSentenceStart(params), params[1]]
}

export function deleteBackwardsTowardsSentenceStart(params) {

    const [selectionStart_, value] = params
    let resultValue = value

    const selectionStart = backwardsTowardsSentenceStart(params)

    resultValue = 
        value.slice(0, selectionStart)
        + (selectionStart_ !== value.length && selectionStart !== 0
            && value[selectionStart_] !== " " ? " " : "")
        + value.slice(selectionStart_, value.length)

    return [selectionStart, resultValue]
}
