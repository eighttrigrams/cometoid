import * as assert from "assert"
import {insertLineAfterCurrent, deleteBackwardsTowardsSentenceStart} from "../js/editor"


function convert(what) {

    const i = what.indexOf("|")
    const result = what.slice(0, i) + what.slice(i + 1, what.length)
    return [i, result]
}

describe("Editor", function() {
    
    describe("insertLineAfterCurrent", function() {

        it("cursor at start of line", function() {
            
            assert.deepEqual(
                insertLineAfterCurrent(
                    convert("|abc")), 
                convert("abc\n|"))
        })
    
        it("cursor at end of line", function() {
            
            assert.deepEqual(insertLineAfterCurrent(
                    convert("abc|")), 
                convert("abc\n|"))
        })
    
        it("cursor somewhere in the line", function() {
            
            assert.deepEqual(insertLineAfterCurrent(
                    convert("a|bc")),
                convert("abc\n|"))
        })
    })

    describe("deleteBackwardsTowardsSentenceStart", function() {
        
        it("cursor at end of line", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc|")), 
                convert("abc.|"))
        })

        it("cursor between sentences", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc. |abc")), 
                convert("abc. abc.| abc"))
        })

        it("cursor between sentences, delete middle", function() {
            
            assert.deepEqual(deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc.| abc")), 
                convert("abc.| abc"))
        })
    })
})
