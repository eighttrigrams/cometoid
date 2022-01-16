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
        
        it("cursor at the very beginning", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("|abc")), 
                convert("|abc"))
        })

        it("delete towards very beginning", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc|")), 
                convert("|"))
        })

        it("delete towards consecutive line breaks", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc\n\nabc|")), 
                convert("abc\n\n|"))
        })

        it("remove one of consecutive line breaks", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc\n\n|")), 
                convert("abc\n|"))
        })

        it("cursor at end of line", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc|")), 
                convert("abc.|"))
        })

        it("cursor between sentences, one whitespace", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc. |abc")), 
                convert("abc.| abc"))
        })

        it("cursor between sentences, multiple whitespaces", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc.  |abc")), 
                convert("abc. abc.| abc"))
        })

        it("cursor between sentences, middle of word", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. a|bc")), 
                convert("abc.| bc"))
        })

        it("cursor between sentences, delete middle", function() {
            
            assert.deepEqual(deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc.| abc")), 
                convert("abc.| abc"))
        })
    })
})
