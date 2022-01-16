import * as assert from "assert"
import {insertLineAfterCurrent} from "../js/editor"


function convert(what) {

    const i = what.indexOf("|")
    const result = what.slice(0, i) + what.slice(i + 1, what.length)
    return [i, result]
}

describe("Array", function() {
    
    it("insertLineAfterCurrent - cursor at start of line", function() {
        
        const [i, line] = convert("|abc")
        const result = insertLineAfterCurrent(i, line)

        assert.deepEqual(result, convert("abc\n|"))
    })

    it("insertLineAfterCurrent - cursor at end of line", function() {
        
        const [i, line] = convert("abc|")
        const result = insertLineAfterCurrent(i, line)

        assert.deepEqual(result, convert("abc\n|"))
    })

    it("insertLineAfterCurrent - cursor somewhere in the line", function() {
        
        const [i, line] = convert("a|bc")
        const result = insertLineAfterCurrent(i, line)

        assert.deepEqual(result, convert("abc\n|"))
    })
})