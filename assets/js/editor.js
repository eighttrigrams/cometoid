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

export function deleteBackwardsTowardsSentenceStart([selectionStart, value]) {

    let resultValue = value
    let offset = 0
    let _selectionStart = selectionStart

    if (selectionStart === 0) return [selectionStart, value]

    if (selectionStart > 2) {
        if (value[selectionStart-1] === "\n" && value[selectionStart-2] === "\n") {
            resultValue = value.slice(0, selectionStart-1) 
                + value.slice(selectionStart, value.length)
            return [selectionStart - 1, resultValue]
        }
    }
    if (selectionStart > 0) {
        if (isSentenceStop(value[selectionStart-1])) selectionStart--
    }
    for (; selectionStart > 0; selectionStart--) {
        if (selectionStart - 1 === 0) {
            resultValue = value.slice(_selectionStart, value.length)
            offset--
            break;
        } else if (isSentenceStop(value[selectionStart-1])) {
            resultValue = 
                value.slice(0, selectionStart)
                + (_selectionStart !== value.length 
                    && value[_selectionStart] !== " " ? " " : "")
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
